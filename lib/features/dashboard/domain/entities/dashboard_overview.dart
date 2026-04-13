class DashboardOverview {
  final DashboardHeader header;
  final ExpeditionSummary expedition;
  final List<DashboardInsight> insights;
  final DashboardCheckpoint nextCheckpoint;
  final List<DashboardTask> tasks;

  const DashboardOverview({
    required this.header,
    required this.expedition,
    required this.insights,
    required this.nextCheckpoint,
    required this.tasks,
  });
}

class DashboardHeader {
  final String dateLabel;
  final String greeting;
  final String location;

  const DashboardHeader({
    required this.dateLabel,
    required this.greeting,
    required this.location,
  });
}

class ExpeditionSummary {
  final String title;
  final String subtitle;
  final String distance;
  final String ascent;
  final String eta;
  final double progress;
  final String statusTag;

  const ExpeditionSummary({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.ascent,
    required this.eta,
    required this.progress,
    required this.statusTag,
  });
}

class DashboardInsight {
  final String title;
  final String value;
  final String hint;
  final String type;

  const DashboardInsight({
    required this.title,
    required this.value,
    required this.hint,
    required this.type,
  });
}

class DashboardCheckpoint {
  final int order;
  final String title;
  final String detail;

  const DashboardCheckpoint({
    required this.order,
    required this.title,
    required this.detail,
  });
}

class DashboardTask {
  final String title;
  final String meta;
  final bool done;

  const DashboardTask({
    required this.title,
    required this.meta,
    required this.done,
  });
}
