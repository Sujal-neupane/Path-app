import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/sos/data/repositories/sos_repository_impl.dart';
import 'package:path_app/features/sos/domain/entities/sos_alert.dart';

class SosState extends Equatable {
  final List<SosAlert> queuedAlerts;
  final SosAlert? lastSentAlert;
  final bool isSending;
  final String? errorMessage;

  const SosState({
    this.queuedAlerts = const [],
    this.lastSentAlert,
    this.isSending = false,
    this.errorMessage,
  });

  SosState copyWith({
    List<SosAlert>? queuedAlerts,
    SosAlert? lastSentAlert,
    bool? isSending,
    String? errorMessage,
  }) {
    return SosState(
      queuedAlerts: queuedAlerts ?? this.queuedAlerts,
      lastSentAlert: lastSentAlert ?? this.lastSentAlert,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [queuedAlerts, lastSentAlert, isSending, errorMessage];
}

final sosViewModelProvider = NotifierProvider<SosNotifier, SosState>(() {
  return SosNotifier();
});

class SosNotifier extends Notifier<SosState> {
  Timer? _syncTimer;

  @override
  SosState build() {
    _loadQueuedAlerts();
    _startSyncTimer();
    
    ref.onDispose(() {
      _syncTimer?.cancel();
    });

    return const SosState();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) => syncQueue());
  }

  Future<void> _loadQueuedAlerts() async {
    final repository = ref.read(sosRepositoryProvider);
    final queued = await repository.getQueuedAlerts();
    state = state.copyWith(queuedAlerts: queued);
  }

  Future<void> triggerSos({
    double? lat,
    double? lng,
    double? alt,
    double? battery,
    String? message,
  }) async {
    final repository = ref.read(sosRepositoryProvider);
    
    final latitude = lat ?? 27.8068;
    final longitude = lng ?? 86.7140;
    final altitude = alt ?? 3440.0;
    final batteryLevel = battery ?? 92.0;

    final alert = SosAlert(
      userId: '', 
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      batteryLevel: batteryLevel,
      status: 'pending',
      message: message ?? 'AMS/Emergency alert triggered.',
      createdAt: DateTime.now(),
      isSynced: false,
    );

    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      final sentAlert = await repository.sendSosAlert(alert);
      state = state.copyWith(
        isSending: false,
        lastSentAlert: sentAlert,
      );
    } catch (e) {
      await repository.saveAlertLocally(alert);
      final queued = await repository.getQueuedAlerts();
      state = state.copyWith(
        isSending: false,
        queuedAlerts: queued,
        errorMessage: 'Offline. SOS saved to offline queue and will retry.',
      );
    }
  }

  Future<void> syncQueue() async {
    final repository = ref.read(sosRepositoryProvider);
    final queued = await repository.getQueuedAlerts();
    if (queued.isEmpty) return;

    for (final alert in queued) {
      try {
        await repository.sendSosAlert(alert);
        await repository.deleteAlertLocally(alert.createdAt.toIso8601String());
      } catch (_) {
        break;
      }
    }

    final refreshedQueued = await repository.getQueuedAlerts();
    state = state.copyWith(queuedAlerts: refreshedQueued);
  }

  Future<void> clearLocalQueue() async {
    final repository = ref.read(sosRepositoryProvider);
    final queued = await repository.getQueuedAlerts();
    for (final alert in queued) {
      await repository.deleteAlertLocally(alert.createdAt.toIso8601String());
    }
    state = state.copyWith(queuedAlerts: []);
  }
}
