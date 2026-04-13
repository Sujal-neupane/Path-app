import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';

final dashboardOverviewProvider =
    FutureProvider.autoDispose<DashboardOverview>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchOverview();
});
