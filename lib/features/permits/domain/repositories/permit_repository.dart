import '../../data/models/permit_info_model.dart';

abstract class PermitRepository {
  Future<List<PermitInfoModel>> getAllPermits();
  Future<PermitInfoModel> getPermitByRegion(String region);
  Future<Map<String, dynamic>> createCheckoutSession({
    required String regionKey,
    required int trekkerCount,
  });
}
