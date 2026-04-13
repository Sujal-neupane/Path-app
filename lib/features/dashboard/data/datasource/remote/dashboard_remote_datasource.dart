import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';
import 'package:path_app/features/dashboard/data/models/dashboard_overview_api_model.dart';

final dashboardRemoteDatasourceProvider = Provider<DashboardRemoteDatasource>((ref) {
  return DashboardRemoteDatasourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class DashboardRemoteDatasource {
  Future<DashboardOverviewApiModel> fetchOverview();
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final ApiClient _apiClient;

  DashboardRemoteDatasourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<DashboardOverviewApiModel> fetchOverview() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardOverview);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return DashboardOverviewApiModel.fromJson(data);
      }

      throw Exception(response.data['message'] ?? 'Failed to load dashboard overview');
    } catch (e) {
      throw Exception('Dashboard overview fetch failed: $e');
    }
  }
}
