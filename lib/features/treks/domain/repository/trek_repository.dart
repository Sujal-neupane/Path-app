import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

abstract class TrekRepository {
  Future<List<TrekSummary>> getAvailableTreks();
  Future<TrekSummary?> getTrekById(String id);
}
