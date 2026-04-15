import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_app/features/trekking/data/datasources/itinerary_local_datasource.dart';
import 'package:path_app/features/trekking/data/datasources/itinerary_local_datasource_impl.dart';
import 'package:path_app/features/trekking/data/datasources/itinerary_remote_datasource.dart';
import 'package:path_app/features/trekking/data/datasources/itinerary_remote_datasource_impl.dart';
import 'package:path_app/features/trekking/data/repositories/itinerary_repository_impl.dart';
import 'package:path_app/features/trekking/domain/entities/itinerary.dart';
import 'package:path_app/features/trekking/domain/repositories/itinerary_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 1: Dependency Injection - Infrastructure
/// ═══════════════════════════════════════════════════════════════════════

/// Reuse existing SharedPreferences provider (from trekking_providers)
/// Import from there when combining providers

// Reuse existing Dio provider (from trekking_providers)
// Import from there when combining providers

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 2: Datasources
/// ═══════════════════════════════════════════════════════════════════════

/// Remote datasource for itinerary API calls
final itineraryRemoteDataSourceProvider =
    Provider<ItineraryRemoteDataSource>((ref) {
  // In real app, would inject Dio from trekking_providers
  // For now, create mock Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    connectTimeout: const Duration(seconds: 30),
  ));

  return ItineraryRemoteDataSourceImpl(dio: dio);
});

/// Local datasource for caching
final itineraryLocalDataSourceProvider = FutureProvider<ItineraryLocalDataSource>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ItineraryLocalDataSourceImpl(prefs: prefs);
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 3: Repository
/// ═══════════════════════════════════════════════════════════════════════

/// Main repository - handles offline-first logic
final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  final remoteDataSource = ref.watch(itineraryRemoteDataSourceProvider);

  // For local datasource, handle async initialization
  return ItineraryRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: ItineraryLocalDataSourceImpl(
      prefs: SharedPreferences.getInstance as SharedPreferences,
    ),
  );
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - FutureProviders (Read Operations)
/// ═══════════════════════════════════════════════════════════════════════

/// Get all user's itineraries
final userItinerariesProvider =
    FutureProvider<List<Itinerary>>((ref) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getUserItineraries();
});

/// Get specific itinerary by ID
/// Usage: ref.watch(itineraryDetailsProvider('itinerary123'))
final itineraryDetailsProvider =
    FutureProvider.family<Itinerary, String>((ref, itineraryId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getItineraryById(itineraryId);
});

/// Get currently active itinerary (if user is on a trek)
final activeItineraryProvider = FutureProvider<Itinerary?>((ref) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getActiveItinerary();
});

/// Get offline-available itineraries
final offlineItinerariesProvider =
    FutureProvider<List<Itinerary>>((ref) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getOfflineItineraries();
});

/// Get last completed day for tracking progress
final lastCompletedDayProvider =
    FutureProvider.family<DateTime?, String>((ref, itineraryId) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.getLastCompletedDayDate(itineraryId);
});

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - No StateNotifier for v1, use simpler approach
/// ═══════════════════════════════════════════════════════════════════════

// Simplified version using FutureProviders only for MVP
// Can upgrade to StateNotifier in Phase 4 if needed

/// ═══════════════════════════════════════════════════════════════════════
/// Layer 4: State Management - Action Providers (One-off operations)
/// ═══════════════════════════════════════════════════════════════════════

/// Create new itinerary from trek
final createItineraryProvider =
    FutureProvider.family<Itinerary?, ({String trekId, String acclimatization})>(
        (ref, params) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.createItinerary(
    trekId: params.trekId,
    acclimatizationPreference: params.acclimatization,
  );
});

/// Cache itinerary for offline
final cacheOfflineProvider = FutureProvider.family<bool, String>((ref, id) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.cacheItineraryForOffline(id);
});

/// Clear offline itinerary
final clearOfflineProvider = FutureProvider.family<bool, String>((ref, id) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  return repository.clearOfflineItinerary(id);
});
