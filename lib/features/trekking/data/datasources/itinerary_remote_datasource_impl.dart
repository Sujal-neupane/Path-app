import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_app/core/errors/exceptions.dart';
import '../models/itinerary_model.dart';
import 'itinerary_remote_datasource.dart';

/// Implementation of ItineraryRemoteDataSource using Dio HTTP client
///
/// Handles all API communication for itineraries.
/// Error conversion: DioException → AppException
///
/// API Endpoints:
/// - GET /api/v1/itineraries - user's itineraries list
/// - GET /api/v1/itineraries/:id - single itinerary
/// - POST /api/v1/itineraries - create from trek
/// - PUT /api/v1/itineraries/:id - update
/// - DELETE /api/v1/itineraries/:id - delete
/// - POST /api/v1/itineraries/:id/activate - set active
/// - GET /api/v1/itineraries/active - get active
/// - POST /api/v1/itineraries/:id/complete-day - mark day done
/// - GET /api/v1/itineraries/search - search
class ItineraryRemoteDataSourceImpl implements ItineraryRemoteDataSource {
  final Dio _dio;

  /// Constructor injection of Dio client
  /// 
  /// Expected to have baseUrl and timeout already configured.
  ItineraryRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ItineraryModel>> getUserItineraries() async {

    try {
      final response = await _dio.get('/api/v1/itineraries');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ItineraryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Failed to fetch itineraries',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        statusCode: 500,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  @override
  Future<ItineraryModel> getItineraryById(String itineraryId) async {
    try {
      final response = await _dio.get('/api/v1/itineraries/$itineraryId');

      if (response.statusCode == 200) {
        return ItineraryModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Failed to fetch itinerary',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        statusCode: 500,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  @override
  Future<ItineraryModel> createItinerary({
    required String trekId,
    required String acclimatizationPreference,
    DateTime? startDate,
  }) async {
    try {
      final payload = {
        'trekId': trekId,
        'acclimatization': acclimatizationPreference,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
      };

      final response = await _dio.post(
        '/api/v1/itineraries',
        data: payload,
      );

      if (response.statusCode == 201) {
        return ItineraryModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Failed to create itinerary',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ValidationException(errors: ['Failed to create itinerary: $e']);
    }
  }

  @override
  Future<ItineraryModel> updateItinerary({
    required String itineraryId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/itineraries/$itineraryId',
        data: updates,
      );

      if (response.statusCode == 200) {
        return ItineraryModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Failed to update itinerary',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ValidationException(errors: ['Failed to update itinerary: $e']);
    }
  }

  @override
  Future<bool> deleteItinerary(String itineraryId) async {
    try {
      final response = await _dio.delete('/api/v1/itineraries/$itineraryId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Failed to delete itinerary',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        statusCode: 500,
        message: 'Delete failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<ItineraryModel> setActiveItinerary(String itineraryId) async {
    try {
      final response = await _dio.post(
        '/api/v1/itineraries/$itineraryId/activate',
      );

      if (response.statusCode == 200) {
        return ItineraryModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Failed to activate itinerary',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        statusCode: 500,
        message: 'Activation failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<ItineraryModel?> getActiveItinerary() async {
    try {
      final response = await _dio.get('/api/v1/itineraries/active');

      if (response.statusCode == 200 && response.data != null) {
        return ItineraryModel.fromJson(response.data as Map<String, dynamic>);
      }

      return null; // No active itinerary
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioException(e);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DateTime?> getLastCompletedDayDate(String itineraryId) async {
    try {
      final response = await _dio.get(
        '/api/v1/itineraries/$itineraryId/last-completed-day',
      );

      if (response.statusCode == 200 && response.data != null) {
        final dateStr = response.data as String?;
        if (dateStr != null) {
          return DateTime.parse(dateStr);
        }
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioException(e);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> completeDayInItinerary({
    required String itineraryId,
    required int dayNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/itineraries/$itineraryId/complete-day',
        data: {'dayNumber': dayNumber},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        statusCode: 500,
        message: 'Failed to complete day: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ItineraryModel>> searchItineraries({
    String? query,
    String? difficultyFilter,
    DateTime? afterDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': ?query,
        'difficulty': ?difficultyFilter,
        if (afterDate != null) 'after': afterDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/api/v1/itineraries/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ItineraryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        statusCode: response.statusCode ?? 500,
        message: 'Search failed',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        statusCode: 500,
        message: 'Search error: ${e.toString()}',
      );
    }
  }

  /// Handle Dio-specific exceptions → App exceptions
  /// 
  /// Conversion logic:
  /// - Timeout → RequestTimeoutException
  /// - No internet → NoInternetException
  /// - Server error (4xx/5xx) → ServerException
  /// - Other → ConnectionLostException
  Exception _handleDioException(DioException e) {
    debugLog('DioException: ${e.type}, status: ${e.response?.statusCode}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return RequestTimeoutException(durationSeconds: 30);

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return NoInternetException();
        }
        return ConnectionLostException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final message = e.response?.data is Map
            ? (e.response?.data as Map)['message'] ?? 'Server error'
            : 'Server error ($statusCode)';
        return ServerException(
          statusCode: statusCode,
          message: message,
          original: e,
        );

      default:
        return ConnectionLostException();
    }
  }
}

void debugLog(String message) {
  if (kDebugMode) {
    print('[ItineraryRemoteDS] $message');
  }
}
