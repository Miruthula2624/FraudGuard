import 'dart:async';
import 'package:flutter/services.dart';

/// Service to receive and listen for shared text from Android ACTION_SEND intents.
class ShareIntentService {
  static const MethodChannel _channel = MethodChannel('com.example.mobile/share_intent');

  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;

  final StreamController<String> _sharedTextStreamController = StreamController<String>.broadcast();
  Stream<String> get sharedTextStream => _sharedTextStreamController.stream;

  String? _lastConsumedText;

  ShareIntentService._internal() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onSharedTextReceived') {
      final dynamic raw = call.arguments;
      if (raw is String) {
        final text = raw.trim();
        if (text.isNotEmpty && text != _lastConsumedText) {
          _lastConsumedText = text;
          _sharedTextStreamController.add(text);
        }
      }
    }
  }

  /// Check for any initial shared text passed during cold app launch
  Future<String?> getInitialSharedText() async {
    try {
      final String? text = await _channel.invokeMethod<String>('getInitialSharedText');
      if (text != null) {
        final trimmed = text.trim();
        if (trimmed.isNotEmpty && trimmed != _lastConsumedText) {
          _lastConsumedText = trimmed;
          return trimmed;
        }
      }
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Reset consumption tracker if needed
  void resetLastConsumed() {
    _lastConsumedText = null;
  }

  /// Dispose stream controller
  void dispose() {
    _sharedTextStreamController.close();
  }
}
