import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_app/core/errors/exceptions.dart';
import '../models/trek_api_model.dart';
import 'trekking_remote_datasource.dart';

/// Implementation of remote trekking datasource
///
/// Uses Dio HTTP client to communicate with backend API
/// Throws specific exceptions for error handling:
/// - [NetworkException] for network failures
/// - [ServerException] for 4xx/5xx responses
class TrekkingRemoteDataSourceImpl implements TrekkingRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = '/api/v1';

  TrekkingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<TrekListApiResponse> getAllTreks({
    int page = 1,
    int pageSize = 10,
    String? locationFilter,
    String? difficultyFilter,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (locationFilter != null) 'location': locationFilter,
        if (difficultyFilter != null) 'difficulty': difficultyFilter,
      };

      final response = await _dio.get(
        '$_baseUrl/treks',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch treks',
          statusCode: response.statusCode ?? 500,
        );
      }

      final data = TrekListApiResponse.fromJson(response.data);
      return data;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch treks');
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TrekApiModel> getTrekById(String trekId) async {
    try {
      final response = await _dio.get('$_baseUrl/treks/$trekId');

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Trek not found',
          statusCode: response.statusCode ?? 404,
        );
      }

      final trekModel = TrekApiModel.fromJson(response.data['data']);
      return trekModel;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(
          message: 'Trek not found',
          statusCode: 404,
        );
      }
      throw _handleDioException(e, 'Failed to fetch trek');
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TrekApiModel> createTrek(Map<String, dynamic> trekData) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/treks',
        data: trekData,
      );

      if (response.statusCode != 201) {
        throw ServerException(
          message: 'Failed to create trek',
          statusCode: response.statusCode ?? 400,
        );
      }

      final createdTrek = TrekApiModel.fromJson(response.data['data']);
      return createdTrek;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data['errors'] as List?;
        throw ServerException(
          message: errors?.join(', ') ?? 'Validation error',
          statusCode: 400,
        );
      }
      throw _handleDioException(e, 'Failed to create trek');
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<TrekApiModel> updateTrek(
    String trekId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/treks/$trekId',
        data: updates,
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to update trek',
          statusCode: response.statusCode ?? 500,
        );
      }

      final updatedTrek = TrekApiModel.fromJson(response.data['data']);
      return updatedTrek;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(
          message: 'Trek not found',
          statusCode: 404,
        );
      }
      if (e.response?.statusCode == 403) {
        throw ServerException(
          message: 'Not authorized',
          statusCode: 403,
        );
      }
      throw _handleDioException(e, 'Failed to update trek');
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> deleteTrek(String trekId) async {
    try {
      final response = await _dio.delete('$_baseUrl/treks/$trekId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }

      throw ServerException(
        message: 'Failed to delete trek',
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(
          message: 'Trek not found',
          statusCode: 404,
        );
      }
      if (e.response?.statusCode == 403) {
        throw ServerException(
          message: 'Not authorized',
          statusCode: 403,
        );
      }
      throw _handleDioException(e, 'Failed to delete trek');
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TrekApiModel>> searchTreks(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/treks/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode != 200) {
        return [];
      }

      final results = (response.data['data'] as List?)
              ?.map((item) => TrekApiModel.fromJson(item))
              .toList() ??
          [];
      return results;
    } on DioException catch (e) {
      // Search failures shouldn't crash the app
      print('Search failed: $e');
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TrekApiModel>> filterTreks({
    String? difficulty,
    int? maxDays,
    String? season,
  }) async {
    try {
      final queryParams = {
        if (difficulty != null) 'difficulty': difficulty,
        if (maxDays != null) 'maxDays': maxDays,
        if (season != null) 'season': season,
      };

      final response = await _dio.get(
        '$_baseUrl/treks/filter',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        return [];
      }

      final results = (response.data['data'] as List?)
              ?.map((item) => TrekApiModel.fromJson(item))
              .toList() ??
          [];
      return results;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to filter treks');
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> downloadTrekData(String trekId) async {
    try {
      // This would download GPX/GeoJSON file and save locally
      // For now, return S3 URL or backend path
      final response = await _dio.get('$_baseUrl/treks/$trekId/download');

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to download trek data',
          statusCode: response.statusCode ?? 500,
        );
      }

      // In real implementation, save file and return local path
      // For now, return the uploaded file path from backend
      return response.data['dataPath'] ?? '';
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to download trek data');
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: $e',
        statusCode: 500,
      );
    }
  }

  /// Handle Dio exceptions and convert to app-specific exceptions
  Exception _handleDioException(DioException e, String message) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return RequestTimeoutException(durationSeconds: 30);
    }

    if (e.type == DioExceptionType.unknown) {
      if (e.error is SocketException) {
        return NoInternetException();
      }
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode ?? 500;
      return ServerException(
        message: e.response?.data['message'] ?? message,
        statusCode: statusCode,
      );
    }

    return ConnectionLostException();
  }
}
