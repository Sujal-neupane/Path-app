import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/treks/data/datasources/trek_local_data_source.dart';
import 'package:path_app/features/treks/data/datasources/trek_remote_data_source.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/domain/repository/trek_repository.dart';

/// Provides the trek repository with remote + local data source injection.
final trekRepositoryProvider = Provider<TrekRepository>((ref) {
  return TrekRepositoryImpl(
    remoteDataSource: ref.read(trekRemoteDataSourceProvider),
    localDataSource: ref.read(trekLocalDataSourceProvider),
  );
});

/// Repository implementing an offline-first data strategy:
///   1. Try remote API (backend database)
///   2. Cache successful responses locally
///   3. Fall back to local cache on network failure
class TrekRepositoryImpl implements TrekRepository {
  final TrekRemoteDataSource _remoteDataSource;
  final TrekLocalDataSource _localDataSource;

  TrekRepositoryImpl({
    required TrekRemoteDataSource remoteDataSource,
    required TrekLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<TrekSummary>> getAvailableTreks() async {
    try {
      // 1. Attempt remote fetch
      final remoteTreks = await _remoteDataSource.fetchOfficialTreks();

      if (remoteTreks.isNotEmpty) {
        // 2. Cache fresh data locally for offline access
        await _localDataSource.cacheTrekList(remoteTreks);
        return remoteTreks;
      }
    } catch (e) {
      // Network failure — fall through to local cache
      // ignore: avoid_print
      print('[TrekRepository] Remote fetch failed: $e — trying local cache.');
    }

    // 3. Fallback to local cache
    final cachedTreks = await _localDataSource.getCachedTrekList();
    if (cachedTreks != null && cachedTreks.isNotEmpty) {
      return cachedTreks;
    }

    // No data available at all
    return [];
  }

  @override
  Future<TrekSummary?> getTrekById(String id) async {
    try {
      // 1. Attempt remote fetch
      final remoteTrek = await _remoteDataSource.fetchTrekById(id);

      if (remoteTrek != null) {
        // 2. Cache for offline access
        await _localDataSource.cacheTrekDetail(remoteTrek);
        return remoteTrek;
      }
    } catch (e) {
      // Network failure — fall through to local cache
      // ignore: avoid_print
      print('[TrekRepository] Remote detail fetch failed: $e — trying cache.');
    }

    // 3. Fallback to local cache
    return _localDataSource.getCachedTrekDetail(id);
  }
}
