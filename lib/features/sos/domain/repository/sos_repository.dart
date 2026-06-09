import 'package:path_app/features/sos/domain/entities/sos_alert.dart';

abstract class SosRepository {
  Future<SosAlert> sendSosAlert(SosAlert alert);
  Future<List<SosAlert>> getQueuedAlerts();
  Future<void> saveAlertLocally(SosAlert alert);
  Future<void> deleteAlertLocally(String timestampKey);
}
