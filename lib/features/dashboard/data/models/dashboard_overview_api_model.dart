import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';

class DashboardOverviewApiModel extends DashboardOverview {
  const DashboardOverviewApiModel({
    required super.header,
    required super.expedition,
    required super.insights,
    required super.nextCheckpoint,
    required super.tasks,
  });

  factory DashboardOverviewApiModel.fromJson(Map<String, dynamic> json) {
    final headerJson = json['header'] as Map<String, dynamic>? ?? {};
    final expeditionJson = json['expedition'] as Map<String, dynamic>? ?? {};
    final checkpointJson = json['nextCheckpoint'] as Map<String, dynamic>? ?? {};

    final insightsList = (json['insights'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => DashboardInsight(
            title: (item['title'] ?? '').toString(),
            value: (item['value'] ?? '').toString(),
            hint: (item['hint'] ?? '').toString(),
            type: (item['type'] ?? 'readiness').toString(),
          ),
        )
        .toList();

    final tasksList = (json['tasks'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => DashboardTask(
            title: (item['title'] ?? '').toString(),
            meta: (item['meta'] ?? '').toString(),
            done: (item['done'] ?? false) as bool,
          ),
        )
        .toList();

    return DashboardOverviewApiModel(
      header: DashboardHeader(
        dateLabel: (headerJson['dateLabel'] ?? '').toString(),
        greeting: (headerJson['greeting'] ?? '').toString(),
        location: (headerJson['location'] ?? '').toString(),
      ),
      expedition: ExpeditionSummary(
        title: (expeditionJson['title'] ?? '').toString(),
        subtitle: (expeditionJson['subtitle'] ?? '').toString(),
        distance: (expeditionJson['distance'] ?? '').toString(),
        ascent: (expeditionJson['ascent'] ?? '').toString(),
        eta: (expeditionJson['eta'] ?? '').toString(),
        progress: ((expeditionJson['progress'] ?? 0.0) as num).toDouble(),
        statusTag: (expeditionJson['statusTag'] ?? '').toString(),
      ),
      insights: insightsList,
      nextCheckpoint: DashboardCheckpoint(
        order: ((checkpointJson['order'] ?? 0) as num).toInt(),
        title: (checkpointJson['title'] ?? '').toString(),
        detail: (checkpointJson['detail'] ?? '').toString(),
      ),
      tasks: tasksList,
    );
  }
}
