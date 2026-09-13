import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';
import '../services/scan_service.dart';

enum ScanStatus {
  idle,
  scanning,
  success,
  error,
}

class ScanProvider extends ChangeNotifier {
  final ScanService _scanService;

  ScanStatus _status = ScanStatus.idle;
  ScanResult? _scanResult;
  String? _errorMessage;

  ScanProvider({ScanService? scanService})
      : _scanService = scanService ?? ScanService();

  ScanStatus get status => _status;
  ScanResult? get scanResult => _scanResult;
  String? get errorMessage => _errorMessage;
  bool get isScanning => _status == ScanStatus.scanning;
  bool get hasResult => _status == ScanStatus.success && _scanResult != null;

  void clearResult() {
    _status = ScanStatus.idle;
    _scanResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Scan suspicious text content
  Future<bool> scanText(String content) async {
    _status = ScanStatus.scanning;
    _errorMessage = null;
    _scanResult = null;
    notifyListeners();

    final response = await _scanService.scanText(content);

    if (response.success && response.result != null) {
      _scanResult = response.result;
      _status = ScanStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = ScanStatus.error;
      _errorMessage = response.message ?? 'Text scan failed.';
      notifyListeners();
      return false;
    }
  }

  /// Scan image file
  Future<bool> scanImage(File imageFile) async {
    _status = ScanStatus.scanning;
    _errorMessage = null;
    _scanResult = null;
    notifyListeners();

    final response = await _scanService.scanImage(imageFile);

    if (response.success && response.result != null) {
      _scanResult = response.result;
      _status = ScanStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = ScanStatus.error;
      _errorMessage = response.message ?? 'Image scan failed.';
      notifyListeners();
      return false;
    }
  }
}
