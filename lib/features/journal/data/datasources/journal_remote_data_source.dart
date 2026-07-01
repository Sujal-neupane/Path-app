import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/api/api_client.dart';
import 'package:path_app/core/api/api_endpoint.dart';

final journalRemoteDataSourceProvider = Provider<JournalRemoteDataSource>((ref) {
  return JournalRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

abstract class JournalRemoteDataSource {
  Future<Map<String, dynamic>> fetchJournalEntries(String trekId);
  Future<Map<String, dynamic>> createJournalEntry(String trekId, Map<String, dynamic> entryData);
  Future<Map<String, dynamic>> updateJournalEntry(String trekId, String entryId, Map<String, dynamic> entryData);
  Future<Map<String, dynamic>> deleteJournalEntry(String trekId, String entryId);
}

class JournalRemoteDataSourceImpl implements JournalRemoteDataSource {
  final ApiClient _apiClient;

  JournalRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> fetchJournalEntries(String trekId) async {
    final response =
        await _apiClient.get('${ApiEndpoints.journalList}/trek/$trekId');
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> createJournalEntry(String trekId, Map<String, dynamic> entryData) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.journalList}/trek/$trekId',
      data: entryData,
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateJournalEntry(String trekId, String entryId, Map<String, dynamic> entryData) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.journalList}/$entryId',
      data: entryData,
    );
    return _extractData(response.data);
  }

  @override
  Future<Map<String, dynamic>> deleteJournalEntry(String trekId, String entryId) async {
    final response =
        await _apiClient.delete('${ApiEndpoints.journalList}/$entryId');
    return _extractData(response.data);
  }

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['success'] == true) {
        return responseData;
      }
      throw Exception(responseData['message'] ?? 'API error');
    }
    throw Exception('Invalid response format');
  }
}
