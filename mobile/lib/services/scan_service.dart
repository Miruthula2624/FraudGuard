import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/scan_result.dart';

class ScanApiResponse {
  final bool success;
  final String? message;
  final ScanResult? result;

  const ScanApiResponse({
    required this.success,
    this.message,
    this.result,
  });
}

class ScanService {
  final ApiClient _apiClient;

  ScanService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Scan suspicious text content via POST /api/scan/text
  Future<ScanApiResponse> scanText(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return const ScanApiResponse(
        success: false,
        message: 'Content cannot be empty.',
      );
    }

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.scanTextEndpoint,
        data: {'content': trimmed},
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        return const ScanApiResponse(
          success: false,
          message: 'Invalid response received from scan service.',
        );
      }

      final scanResult = ScanResult.fromJson(data);
      return ScanApiResponse(
        success: true,
        result: scanResult,
      );
    } on DioException catch (e) {
      return ScanApiResponse(
        success: false,
        message: _extractErrorMessage(e, defaultMessage: 'Failed to complete text scan.'),
      );
    } catch (e) {
      return ScanApiResponse(
        success: false,
        message: 'An unexpected error occurred while scanning text: $e',
      );
    }
  }

  /// Scan image file via POST /api/scan/file
  Future<ScanApiResponse> scanImage(File imageFile) async {
    if (!await imageFile.exists()) {
      return const ScanApiResponse(
        success: false,
        message: 'Selected image file does not exist on device.',
      );
    }

    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.scanFileEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        return const ScanApiResponse(
          success: false,
          message: 'Invalid response received from image scan service.',
        );
      }

      final scanResult = ScanResult.fromJson(data);
      return ScanApiResponse(
        success: true,
        result: scanResult,
      );
    } on DioException catch (e) {
      return ScanApiResponse(
        success: false,
        message: _extractErrorMessage(e, defaultMessage: 'Failed to complete image scan.'),
      );
    } catch (e) {
      return ScanApiResponse(
        success: false,
        message: 'An unexpected error occurred while scanning image: $e',
      );
    }
  }

  /// Check ML backend service health
  Future<bool> checkMlStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.mlStatusEndpoint);
      return response.data?['mlOnline'] == true;
    } catch (_) {
      return false;
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
        return 'Scan timed out. The analysis service took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the FraudGuard scanning server. Please ensure the backend is running.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 400) return 'Invalid content or unsupported file format.';
        if (status == 401) return 'Session expired. Please log in again.';
        if (status == 413) return 'Image file is too large for upload.';
        if (status == 500) return 'Server error encountered during analysis. Please try again.';
        return defaultMessage;
      default:
        return defaultMessage;
    }
  }
}
