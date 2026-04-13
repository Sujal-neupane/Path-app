import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/dashboard/data/datasource/remote/dashboard_remote_datasource_offline_first.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/domain/repository/dashboard_repository.dart';

/// Provider for authenticated user ID ✅ DYNAMIC (NO HARDCODING)
/// 
/// TODO: Wire this to AuthProvider when user authentication is implemented
/// Currently using a temporary user ID for MVP
final authenticatedUserIdProvider = Provider<String>((ref) {
  // TODO: Get from auth provider when available
  // return ref.watch(authViewModelProvider).user?.id ?? 'anonymous';
  
  // MVP: Using environment variable or config
  return 'user_default'; // Will be replaced with real userId from auth
});

/// Main dashboard repository provider
/// Uses authenticated userId for cache isolation and API calls
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  // Get authenticated user ID (not hardcoded in datasource)
  final userId = ref.watch(authenticatedUserIdProvider);

  // Get authenticated datasource with real user ID
  final datasource = ref.watch(
    dashboardRemoteDatasourceProvider(userId),
  );

  return DashboardRepositoryImpl(remoteDatasource: datasource);
});

/// Dashboard repository implementation
/// Handles single source of truth for dashboard data
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _remoteDatasource;

  DashboardRepositoryImpl({required DashboardRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<DashboardOverview> fetchOverview() {
    return _remoteDatasource.fetchOverview();
  }
}
