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
