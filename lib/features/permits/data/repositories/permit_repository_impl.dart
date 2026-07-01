import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/permit_repository.dart';
import '../datasources/permit_remote_data_source.dart';
import '../models/permit_info_model.dart';

final permitRepositoryProvider = Provider<PermitRepository>((ref) {
  return PermitRepositoryImpl(
    remoteDataSource: ref.read(permitRemoteDataSourceProvider),
  );
});

class PermitRepositoryImpl implements PermitRepository {
  final PermitRemoteDataSource _remoteDataSource;

  PermitRepositoryImpl({required PermitRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<PermitInfoModel>> getAllPermits() async {
    final response = await _remoteDataSource.fetchAllPermits();
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((json) => PermitInfoModel.fromJson(json)).toList();
  }

  @override
  Future<PermitInfoModel> getPermitByRegion(String region) async {
    final response = await _remoteDataSource.fetchPermitByRegion(region);
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('No permit data for $region');
    }
    return PermitInfoModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> createCheckoutSession({
    required String regionKey,
    required int trekkerCount,
  }) async {
    final response = await _remoteDataSource.createCheckoutSession(
      regionKey: regionKey,
      trekkerCount: trekkerCount,
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }
}
