import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/dashboard/data/datasource/remote/dashboard_remote_datasource_offline_first.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';
import 'package:path_app/core/storage/token_storage_sevice.dart';

/// Provider for authenticated user ID ✅ DYNAMIC (NO HARDCODING)
final authenticatedUserIdProvider = FutureProvider<String>((ref) async {
  final session = await ref.watch(authSessionControllerProvider.future);
  final sessionUserId = session.user?.id;
  if (sessionUserId != null && sessionUserId.isNotEmpty) {
    return sessionUserId;
  }

  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  final storedUserId = await tokenStorage.getUserId();
  if (storedUserId != null && storedUserId.isNotEmpty) {
    return storedUserId;
  }

  return 'guest';
});

/// Main dashboard repository provider
/// Uses authenticated userId for cache isolation and API calls
final dashboardRepositoryProvider = FutureProvider<DashboardRepository>((
  ref,
) async {
  // Get authenticated user ID (not hardcoded in datasource)
  final userId = await ref.watch(authenticatedUserIdProvider.future);

  // Get authenticated datasource with real user ID
  final datasource = ref.watch(dashboardRemoteDatasourceProvider(userId));

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
