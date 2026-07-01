import 'package:flutter_riverpod/legacy.dart';
import 'package:path_app/features/gear/data/datasources/gear_remote_data_source.dart';

class GearItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool isPacked;
  final bool isEssential;

  const GearItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.isPacked,
    required this.isEssential,
  });

  factory GearItem.fromJson(Map<String, dynamic> json) => GearItem(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    name: (json['name'] as String?) ?? 'Item',
    category: (json['category'] as String?) ?? 'other',
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    isPacked: (json['is_packed'] as bool?) ?? false,
    isEssential: (json['is_essential'] as bool?) ?? false,
  );
}

class GearState {
  final List<GearItem> items;
  final bool isLoading;
  final String? error;

  const GearState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  int get packedCount => items.where((i) => i.isPacked).length;
  double get progress => items.isEmpty ? 0 : packedCount / items.length;

  /// Items grouped by category, preserving first-seen order.
  Map<String, List<GearItem>> get byCategory {
    final map = <String, List<GearItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  GearState copyWith({List<GearItem>? items, bool? isLoading, String? error}) {
    return GearState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GearViewModel extends StateNotifier<GearState> {
  final GearRemoteDataSource _dataSource;
  final String trekId;

  GearViewModel(this._dataSource, this.trekId) : super(const GearState()) {
    load();
  }

  List<GearItem> _parse(Map<String, dynamic> res) {
    final data = res['data'];
    final raw = data is Map<String, dynamic> ? data['items'] : null;
    return (raw is List ? raw : <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(GearItem.fromJson)
        .toList();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dataSource.fetchGearList(trekId);
      state = state.copyWith(items: _parse(res), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load your gear list.',
      );
    }
  }

  Future<void> toggle(GearItem item) async {
    // Optimistic flip
    state = state.copyWith(
      items: [
        for (final i in state.items)
          if (i.id == item.id)
            GearItem(
              id: i.id,
              name: i.name,
              category: i.category,
              quantity: i.quantity,
              isPacked: !i.isPacked,
              isEssential: i.isEssential,
            )
          else
            i,
      ],
    );
    try {
      final res = await _dataSource.togglePackedStatus(trekId, item.id);
      state = state.copyWith(items: _parse(res));
    } catch (_) {
      // Revert on failure by reloading.
      await load();
    }
  }

  Future<void> addItem(String name, String category, int quantity) async {
    try {
      final res = await _dataSource.addGearItem(trekId, {
        'name': name,
        'category': category,
        'quantity': quantity,
        'is_essential': false,
      });
      state = state.copyWith(items: _parse(res));
    } catch (e) {
      state = state.copyWith(error: 'Could not add item.');
    }
  }
}

final gearViewModelProvider = StateNotifierProvider.family<GearViewModel,
    GearState, String>((ref, trekId) {
  return GearViewModel(ref.read(gearRemoteDataSourceProvider), trekId);
});
