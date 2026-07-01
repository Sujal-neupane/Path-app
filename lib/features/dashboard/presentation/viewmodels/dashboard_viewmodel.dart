import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:path_app/features/dashboard/domain/entities/dashboard_overview.dart';

final dashboardOverviewProvider = FutureProvider.autoDispose<DashboardOverview>(
  (ref) async {
    final repository = await ref.watch(dashboardRepositoryProvider.future);
    
    // Periodically invalidate the provider to trigger automatic background refreshes ("realtime")
    final timer = Timer(const Duration(seconds: 15), () {
      ref.invalidateSelf();
    });
    
    ref.onDispose(() {
      timer.cancel();
    });

    return repository.fetchOverview();
  },
);
