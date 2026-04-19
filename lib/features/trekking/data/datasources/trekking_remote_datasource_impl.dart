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
  static const String _baseUrl = '';

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
        'limit': pageSize,
        if (locationFilter != null && locationFilter.isNotEmpty)
          'region': locationFilter,
        if (difficultyFilter != null && difficultyFilter.isNotEmpty)
          'difficulty': difficultyFilter,
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

      final body = response.data as Map<String, dynamic>;
      final items = (body['data'] as List<dynamic>? ?? const [])
          .map((item) => TrekApiModel.fromJson(_mapBackendTrek(item as Map<String, dynamic>)))
          .toList();

      final meta = (body['meta'] as Map<String, dynamic>? ?? const {});

      return TrekListApiResponse(
        success: body['success'] == true,
        data: items,
        total: (meta['total'] as num?)?.toInt() ?? items.length,
        page: (meta['page'] as num?)?.toInt() ?? page,
        pageSize: (meta['limit'] as num?)?.toInt() ?? pageSize,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
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

      final trekModel = TrekApiModel.fromJson(
        _mapBackendTrek(response.data['data'] as Map<String, dynamic>),
      );
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

      final createdTrek = TrekApiModel.fromJson(
        _mapBackendTrek(response.data['data'] as Map<String, dynamic>),
      );
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

      final updatedTrek = TrekApiModel.fromJson(
        _mapBackendTrek(response.data['data'] as Map<String, dynamic>),
      );
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
              ?.map((item) => TrekApiModel.fromJson(_mapBackendTrek(item as Map<String, dynamic>)))
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
        if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
        if (maxDays != null) 'maxDays': maxDays,
        if (season != null && season.isNotEmpty) 'season': season,
      };

      final response = await _dio.get(
        '$_baseUrl/treks/filter',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        return [];
      }

            final results = (response.data['data'] as List?)
              ?.map((item) => TrekApiModel.fromJson(_mapBackendTrek(item as Map<String, dynamic>)))
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

  Map<String, dynamic> _mapBackendTrek(Map<String, dynamic> raw) {
    final checkpoints = (raw['checkpoints'] as List<dynamic>? ?? const []);
    final maxAltitude = checkpoints.fold<double>(
      0,
      (previousValue, item) {
        final altitude = ((item as Map<String, dynamic>)['altitude_m'] as num?)?.toDouble() ?? 0;
        return altitude > previousValue ? altitude : previousValue;
      },
    );

    final startDate = DateTime.tryParse((raw['start_date'] ?? '').toString());
    final endDate = DateTime.tryParse((raw['end_date'] ?? '').toString());
    final estimatedDays =
        (startDate != null && endDate != null) ? endDate.difference(startDate).inDays.abs() + 1 : 1;

    return {
      '_id': (raw['id'] ?? raw['_id'] ?? '').toString(),
      'name': (raw['title'] ?? 'Untitled Trek').toString(),
      'location': (raw['region'] ?? 'Unknown').toString(),
      'description': (raw['notes'] ?? '').toString(),
      'totalDistance': ((raw['expected_distance_km'] as num?) ?? 0).toDouble(),
      'totalElevationGain': ((raw['expected_elevation_gain_m'] as num?) ?? 0).toDouble(),
      'maxAltitude': maxAltitude,
      'estimatedDays': estimatedDays,
      'difficultyRating': (raw['difficulty'] ?? 'moderate').toString(),
      'bestSeason': 'spring',
      'routePoints': <Map<String, dynamic>>[],
      // Reuse this field for cover image until dedicated image fields are added across the Flutter domain model.
      'routeDataPath': raw['cover_image_url'],
      'permitsRequired': null,
      'createdAt': (raw['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      'updatedAt': (raw['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
      'createdBy': (raw['user_id'] ?? 'system').toString(),
      'isOfficial': (raw['is_official'] as bool?) ?? false,
      'completionCount': 0,
      'averageRating': 0.0,
    };
  }
}
