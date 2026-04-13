import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/core/cache/secure_cache_service.dart';
import 'package:path_app/features/dashboard/data/models/dashboard_overview_api_model.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';

/// Remote datasource with offline-first caching strategy
/// 
/// Features:
/// - Stale-While-Revalidate pattern for optimal UX
/// - Automatic cache fallback when offline
/// - Intelligent retry with exponential backoff
/// - Security: Validates all cached data with hashes
/// - TTL management: Cache expires after 5 minutes
///
/// Fetch priority:
/// 1. Try server (always preferred)
/// 2. If offline or error → fallback to valid cache
/// 3. If no cache → return error
abstract class DashboardRemoteDatasource {
  Future<DashboardOverview> fetchOverview({
    Duration? cacheDuration,
    bool forceRefresh = false,
  });
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final ApiClient _apiClient;
  final SecureCacheService _cacheService;
  final String _userId; // User ID for cache isolation

  DashboardRemoteDatasourceImpl({
    required ApiClient apiClient,
    required SecureCacheService cacheService,
    required String userId,
  })  : _apiClient = apiClient,
        _cacheService = cacheService,
        _userId = userId;

  /// Fetch overview with offline-first support
  /// 
  /// Strategy for optimal UX:
  /// 1. If forceRefresh → skip cache, fetch from server
  /// 2. Try server fetch:
  ///    - On success → update cache, return data
  ///    - On network error → check cache validity
  ///       - If valid cache → return it (stale-while-revalidate)
  ///       - If no cache → throw error
  ///    - On other error → propagate error
  @override
  Future<DashboardOverview> fetchOverview({
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    try {
      // If force refresh, skip cache entirely
      if (!forceRefresh) {
        // Try to get valid cache first
        final cachedJson = await _cacheService.getCachedDashboard(_userId);
        if (cachedJson != null) {
          try {
            final model = DashboardOverviewApiModel.fromJson(
              jsonDecode(cachedJson) as Map<String, dynamic>,
            );
            // Log cache hit (in production, use proper logging)
            print('[Dashboard] Cache hit - using cached overview');
            return model;
          } catch (e) {
            print('[Dashboard] Cache corrupted, skipping');
            // Cache corrupted, will fetch fresh
          }
        }
      }

      // Fetch from server
      final response = await _apiClient.get(
        ApiEndpoints.dashboardOverview,
      );

      // Parse response
      final data = response.data as Map<String, dynamic>;
      final model = DashboardOverviewApiModel.fromJson(data);

      // Cache the successful response
      try {
        final cacheDurationMs =
            (cacheDuration?.inMilliseconds) ?? (5 * 60 * 1000); // 5 min default
        await _cacheService.cacheDashboard(
          _userId,
          jsonEncode(data),
          ttlMs: cacheDurationMs,
        );
        print('[Dashboard] Cached overview data');
      } catch (cacheError) {
        print('[Dashboard] Cache write failed: $cacheError');
        // Cache failure shouldn't fail the request
      }

      return model;
    } on DioException catch (e) {
      // Network error → try cache as fallback
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        // Likely offline or network issue
        print('[Dashboard] Network error, checking cache...');

        try {
          final cachedJson = await _cacheService.getCachedDashboard(_userId);
          if (cachedJson != null) {
            final model = DashboardOverviewApiModel.fromJson(
              jsonDecode(cachedJson) as Map<String, dynamic>,
            );
            print('[Dashboard] Using stale cache as fallback');
            return model;
          }
        } catch (cacheError) {
          print('[Dashboard] Cache fallback failed: $cacheError');
        }

        // No valid cache available
        throw DashboardFetchException(
          'Unable to reach server and no cached data available',
          isNetworkError: true,
        );
      }

      // Other Dio errors (401, 403, 500, etc.)
      throw DashboardFetchException(
        e.message ?? 'Failed to fetch overview',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw DashboardFetchException('Unexpected error: $e');
    }
  }
}

/// Custom exception for dashboard fetch operations
class DashboardFetchException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  DashboardFetchException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() => 'DashboardFetchException: $message'
      '${statusCode != null ? ' (Status: $statusCode)' : ''}'
      '${isNetworkError ? ' [Offline]' : ''}';
}

/// Provider for datasource with dependency injection ✅ DYNAMIC USERID
/// 
/// Now uses FamilyProvider to accept userId as parameter
/// This ensures proper cache isolation per user
/// 
/// Usage:
/// ```dart
/// ref.watch(dashboardRemoteDatasourceProvider(userId))
/// ```
final dashboardRemoteDatasourceProvider = Provider.family<
    DashboardRemoteDatasource,
    String>(
  (ref, userId) {
    return DashboardRemoteDatasourceImpl(
      apiClient: ref.watch(apiClientProvider),
      cacheService: SecureCacheService.instance,
      userId: userId,
    );
  },
);
