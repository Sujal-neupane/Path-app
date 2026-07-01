import 'package:flutter_riverpod/legacy.dart';
import 'package:path_app/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String level;
  final String formattedValue;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    required this.level,
    required this.formattedValue,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] as String?) ?? 'Anonymous Trekker',
      avatarUrl: json['avatarUrl'] as String?,
      level: (json['level'] as String?) ?? 'rookie',
      formattedValue: (json['formattedValue'] as String?) ?? '—',
    );
  }
}

/// Ranking metric the leaderboard is sorted by.
enum LeaderboardType { xp, distance, elevation, treks }

extension LeaderboardTypeX on LeaderboardType {
  String get apiValue => switch (this) {
    LeaderboardType.xp => 'xp',
    LeaderboardType.distance => 'distance',
    LeaderboardType.elevation => 'elevation',
    LeaderboardType.treks => 'treks',
  };

  String get label => switch (this) {
    LeaderboardType.xp => 'XP',
    LeaderboardType.distance => 'Distance',
    LeaderboardType.elevation => 'Elevation',
    LeaderboardType.treks => 'Treks',
  };
}

class LeaderboardState {
  final LeaderboardType type;
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.type = LeaderboardType.xp,
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    LeaderboardType? type,
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      type: type ?? this.type,
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final LeaderboardRemoteDataSource _dataSource;

  LeaderboardViewModel(this._dataSource) : super(const LeaderboardState()) {
    load(LeaderboardType.xp);
  }

  Future<void> load(LeaderboardType type) async {
    state = state.copyWith(type: type, isLoading: true, error: null);
    try {
      final res = await _dataSource.fetchLeaderboard(
        type: type.apiValue,
        period: 'all',
      );
      final data = res['data'];
      final rawList = data is Map<String, dynamic> ? data['data'] : data;
      final list = (rawList is List ? rawList : <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntry.fromJson)
          .toList();
      state = state.copyWith(entries: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load the leaderboard.',
      );
    }
  }
}

final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>((ref) {
  return LeaderboardViewModel(ref.read(leaderboardRemoteDataSourceProvider));
});
