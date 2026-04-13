import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/dashboard/data/datasource/remote/dashboard_remote_datasource.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:path_app/features/dashboard/domain/repository/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDatasource = ref.watch(dashboardRemoteDatasourceProvider);
  return DashboardRepositoryImpl(remoteDatasource: remoteDatasource);
});

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _remoteDatasource;

  DashboardRepositoryImpl({required DashboardRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<DashboardOverview> fetchOverview() {
    return _remoteDatasource.fetchOverview();
  }
}
