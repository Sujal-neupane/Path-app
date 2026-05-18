import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/treks/data/trek_seed_data.dart';
import 'package:path_app/features/treks/domain/entities/trek_summary.dart';
import 'package:path_app/features/treks/domain/repository/trek_repository.dart';

final trekRepositoryProvider = Provider<TrekRepository>((ref) {
  return TrekRepositoryImpl();
});

class TrekRepositoryImpl implements TrekRepository {
  @override
  Future<List<TrekSummary>> getAvailableTreks() async {
    return List<TrekSummary>.from(trekSeedData);
  }

  @override
  Future<TrekSummary?> getTrekById(String id) async {
    return findTrekById(id);
  }
}
