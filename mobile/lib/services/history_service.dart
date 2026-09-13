import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/scan_history.dart';

class HistoryApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const HistoryApiResponse({
    required this.success,
    this.message,
    this.data,
  });
}

class HistoryService {
  final ApiClient _apiClient;

  HistoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch all scan history items for the authenticated user via GET /api/history
  Future<HistoryApiResponse<List<ScanHistoryItem>>> fetchHistory() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.historyEndpoint);

      final rawData = response.data;
      if (rawData is! List) {
        return const HistoryApiResponse(
          success: false,
          message: 'Invalid response format received from server.',
        );
      }

      final items = rawData
          .whereType<Map<String, dynamic>>()
          .map((json) => ScanHistoryItem.fromJson(json))
          .toList();

      return HistoryApiResponse(
        success: true,
        data: items,
      );
    } on DioException catch (e) {
      return HistoryApiResponse(
        success: false,
        message: _extractErrorMessage(e, defaultMessage: 'Failed to retrieve scan history.'),
      );
    } catch (e) {
      return HistoryApiResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Delete a scan history item by ID via DELETE /api/history/:id
  Future<HistoryApiResponse<void>> deleteHistoryItem(int id) async {
    try {
      final endpoint = ApiConstants.deleteHistoryEndpoint(id);
      final response = await _apiClient.dio.delete(endpoint);

      final message = response.data?['message']?.toString() ?? 'History item deleted';
      return HistoryApiResponse(
        success: true,
        message: message,
      );
    } on DioException catch (e) {
      return HistoryApiResponse(
        success: false,
        message: _extractErrorMessage(e, defaultMessage: 'Failed to delete history item.'),
      );
    } catch (e) {
      return HistoryApiResponse(
        success: false,
        message: 'An unexpected error occurred while deleting item: $e',
      );
    }
  }

  String _extractErrorMessage(DioException e, {required String defaultMessage}) {
    if (e.response != null && e.response?.data is Map) {
      final message = e.response!.data['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your network connection.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the server. Please ensure the backend is running.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return 'Session expired. Please sign in again.';
        if (status == 404) return 'The requested history item was not found.';
        if (status == 500) return 'Server error processing history. Please try again later.';
        return defaultMessage;
      default:
        return defaultMessage;
    }
  }
}
