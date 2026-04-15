import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_app/features/trekking/data/datasources/trekking_local_datasource.dart';
import 'package:path_app/features/trekking/data/datasources/trekking_local_datasource_impl.dart';
import 'package:path_app/features/trekking/data/datasources/trekking_remote_datasource.dart';
import 'package:path_app/features/trekking/data/datasources/trekking_remote_datasource_impl.dart';
import 'package:path_app/features/trekking/data/repositories/trekking_repository_impl.dart';
import 'package:path_app/features/trekking/domain/entities/trek.dart';
import 'package:path_app/features/trekking/domain/repositories/trekking_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:state_notifier/state_notifier.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 1: Dependency Injection
/// ═══════════════════════════════════════════════════════════════════════

/// Provides SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This should be initialized in main.dart
  // For now, return mock - will throw if not set up
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provides Dio HTTP client instance
final dioProvider = Provider<Dio>((ref) {
  // This should be initialized in main.dart with proper interceptors
  final dio = Dio();
  dio.options.baseUrl = 'http://localhost:3000'; // TODO: Use env config
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  return dio;
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 2: Datasources
/// ═══════════════════════════════════════════════════════════════════════

/// Provides remote API datasource
final trekkingRemoteDataSourceProvider =
    Provider<TrekkingRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return TrekkingRemoteDataSourceImpl(dio: dio);
});

/// Provides local cache datasource
final trekkingLocalDataSourceProvider =
    Provider<TrekkingLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TrekkingLocalDataSourceImpl(prefs: prefs);
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 3: Repository
/// ═══════════════════════════════════════════════════════════════════════

/// Provides the main trekking repository (offline-first implementation)
final trekkingRepositoryProvider = Provider<TrekkingRepository>((ref) {
  final remote = ref.watch(trekkingRemoteDataSourceProvider);
  final local = ref.watch(trekkingLocalDataSourceProvider);

  return TrekkingRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - Treks List
/// ═══════════════════════════════════════════════════════════════════════

/// State for pagination
class TrekListState {
  final List<Trek> treks;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final String? error;
  final String? locationFilter;
  final String? difficultyFilter;

  TrekListState({
    this.treks = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.error,
    this.locationFilter,
    this.difficultyFilter,
  });

  TrekListState copyWith({
    List<Trek>? treks,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    String? error,
    String? locationFilter,
    String? difficultyFilter,
  }) {
    return TrekListState(
      treks: treks ?? this.treks,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      locationFilter: locationFilter ?? this.locationFilter,
      difficultyFilter: difficultyFilter ?? this.difficultyFilter,
    );
  }
}

/// State notifier for trek list management
class TrekListNotifier extends StateNotifier<TrekListState> {
  final TrekkingRepository _repository;

  TrekListNotifier(this._repository) : super(TrekListState());

  /// Fetch treks for given page
  Future<void> fetchTreks({
    int page = 1,
    int pageSize = 10,
    String? locationFilter,
    String? difficultyFilter,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final treks = await _repository.getAllTreks(
        page: page,
        pageSize: pageSize,
        locationFilter: locationFilter,
        difficultyFilter: difficultyFilter,
      );

      state = state.copyWith(
        treks: treks,
        currentPage: page,
        isLoading: false,
        locationFilter: locationFilter,
        difficultyFilter: difficultyFilter,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages) {
      await fetchTreks(
        page: state.currentPage + 1,
        locationFilter: state.locationFilter,
        difficultyFilter: state.difficultyFilter,
      );
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await fetchTreks(
        page: state.currentPage - 1,
        locationFilter: state.locationFilter,
        difficultyFilter: state.difficultyFilter,
      );
    }
  }

  /// Refresh current page
  Future<void> refreshTreks() async {
    await fetchTreks(
      page: state.currentPage,
      locationFilter: state.locationFilter,
      difficultyFilter: state.difficultyFilter,
    );
  }

  /// Search treks
  Future<void> searchTreks(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(treks: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _repository.searchTreks(query);
      state = state.copyWith(treks: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Filter treks
  Future<void> filterTreks({
    String? difficulty,
    int? maxDays,
    String? season,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _repository.filterTreks(
        difficulty: difficulty,
        maxDays: maxDays,
        season: season,
      );
      state = state.copyWith(
        treks: results,
        isLoading: false,
        difficultyFilter: difficulty,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

/// Provider for trek list state management
final trekListProvider =
    StateNotifierProvider.autoDispose<TrekListNotifier, TrekListState>((ref) {
  final repository = ref.watch(trekkingRepositoryProvider);
  return TrekListNotifier(repository);
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - Trek Details
/// ═══════════════════════════════════════════════════════════════════════

/// Provider for single trek details (with caching by trek ID)
final trekDetailsProvider =
    FutureProvider.family<Trek, String>((ref, trekId) async {
  final repository = ref.watch(trekkingRepositoryProvider);
  return repository.getTrekById(trekId);
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - Offline Treks
/// ═══════════════════════════════════════════════════════════════════════

/// Provider for offline-available treks
final offlineTreksProvider = FutureProvider<List<Trek>>((ref) async {
  final repository = ref.watch(trekkingRepositoryProvider);
  return repository.getOfflineTreks();
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - Trek Actions
/// ═══════════════════════════════════════════════════════════════════════

/// Create new trek
final createTrekProvider =
    FutureProvider.family<Trek, Trek>((ref, trek) async {
  final repository = ref.watch(trekkingRepositoryProvider);
  final created = await repository.createTrek(trek);

  // Refresh trek list
  _ = ref.refresh(trekListProvider);

  return created;
});

/// Update existing trek
final updateTrekProvider = FutureProvider.family<Trek,
    ({String trekId, Map<String, dynamic> updates})>((ref, params) async {
  final repository = ref.watch(trekkingRepositoryProvider);
  final updated = await repository.updateTrek(params.trekId, params.updates);

  // Refresh trek list and details
  _ = ref.refresh(trekListProvider);
  _ = ref.refresh(trekDetailsProvider(params.trekId));

  return updated;
});

/// Delete trek
final deleteTrekProvider =
    FutureProvider.family<bool, String>((ref, trekId) async {
  final repository = ref.watch(trekkingRepositoryProvider);
  final success = await repository.deleteTrek(trekId);

  if (success) {
    // Refresh trek list
    _ = ref.refresh(trekListProvider);
  }

  return success;
});

/// Download trek for offline use
final downloadTrekProvider =
    FutureProvider.family<String, String>((ref, trekId) async {
  final repository = ref.watch(trekkingRepositoryProvider);
  final filePath = await repository.downloadTrekForOffline(trekId);

  // Refresh offline treks list
  _ = ref.refresh(offlineTreksProvider);

  return filePath;
});
