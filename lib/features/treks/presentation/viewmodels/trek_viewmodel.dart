import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/treks/data/repositories/trek_repository_impl.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

final trekListProvider = FutureProvider<List<TrekSummary>>((ref) async {
  final repository = ref.watch(trekRepositoryProvider);
  return repository.getAvailableTreks();
});

final trekDetailsProvider = FutureProvider.family<TrekSummary?, String>((
  ref,
  trekId,
) async {
  final repository = ref.watch(trekRepositoryProvider);
  return repository.getTrekById(trekId);
});

class ActiveTrekState {
  final String? region;
  final int currentCheckpointIndex;
  final double distanceWalkedKm;
  final bool isFinished;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? currentAltitude;
  final int totalCheckpoints;

  const ActiveTrekState({
    this.region,
    this.currentCheckpointIndex = 0,
    this.distanceWalkedKm = 0.0,
    this.isFinished = false,
    this.currentLatitude,
    this.currentLongitude,
    this.currentAltitude,
    this.totalCheckpoints = 0,
  });

  ActiveTrekState copyWith({
    String? region,
    int? currentCheckpointIndex,
    double? distanceWalkedKm,
    bool? isFinished,
    double? currentLatitude,
    double? currentLongitude,
    double? currentAltitude,
    int? totalCheckpoints,
  }) {
    return ActiveTrekState(
      region: region ?? this.region,
      currentCheckpointIndex: currentCheckpointIndex ?? this.currentCheckpointIndex,
      distanceWalkedKm: distanceWalkedKm ?? this.distanceWalkedKm,
      isFinished: isFinished ?? this.isFinished,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentAltitude: currentAltitude ?? this.currentAltitude,
      totalCheckpoints: totalCheckpoints ?? this.totalCheckpoints,
    );
  }
}

class ActiveTrekNotifier extends Notifier<ActiveTrekState> {
  @override
  ActiveTrekState build() {
    return const ActiveTrekState();
  }

  void startTrek(String region, {int? totalCheckpoints}) {
    state = ActiveTrekState(
      region: region,
      totalCheckpoints: totalCheckpoints ?? 0,
    );
  }

  void updateProgress({
    required String region,
    required int currentIndex,
    required double distanceWalkedKm,
    required bool isFinished,
    double? latitude,
    double? longitude,
    double? altitude,
    int? totalCheckpoints,
  }) {
    state = ActiveTrekState(
      region: region,
      currentCheckpointIndex: currentIndex,
      distanceWalkedKm: distanceWalkedKm,
      isFinished: isFinished,
      currentLatitude: latitude,
      currentLongitude: longitude,
      currentAltitude: altitude,
      totalCheckpoints: totalCheckpoints ?? state.totalCheckpoints,
    );
  }

  void clearTrek() {
    state = const ActiveTrekState();
  }
}

final activeTrekProvider = NotifierProvider<ActiveTrekNotifier, ActiveTrekState>(() {
  return ActiveTrekNotifier();
});
