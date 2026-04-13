import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';

abstract class DashboardRepository {
  Future<DashboardOverview> fetchOverview();
}
