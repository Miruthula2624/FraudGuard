import 'package:flutter/foundation.dart';
import '../models/scan_history.dart';
import '../services/history_service.dart';

enum HistoryStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService;

  HistoryStatus _status = HistoryStatus.initial;
  List<ScanHistoryItem> _items = [];
  String? _errorMessage;
  int? _deletingItemId;

  HistoryProvider({HistoryService? historyService})
      : _historyService = historyService ?? HistoryService();

  HistoryStatus get status => _status;
  List<ScanHistoryItem> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  int? get deletingItemId => _deletingItemId;

  bool get isLoading => _status == HistoryStatus.loading;
  bool get isEmpty => _status == HistoryStatus.empty || (_status == HistoryStatus.loaded && _items.isEmpty);
  bool get hasError => _status == HistoryStatus.error && _errorMessage != null;

  /// Clear any active error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Reset provider state (e.g. on logout)
  void reset() {
    _status = HistoryStatus.initial;
    _items = [];
    _errorMessage = null;
    _deletingItemId = null;
    notifyListeners();
  }

  /// Fetch history from backend
  Future<void> fetchHistory() async {
    _status = HistoryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _historyService.fetchHistory();

    if (response.success && response.data != null) {
      _items = response.data!;
      if (_items.isEmpty) {
        _status = HistoryStatus.empty;
      } else {
        _status = HistoryStatus.loaded;
      }
      _errorMessage = null;
    } else {
      _status = HistoryStatus.error;
      _errorMessage = response.message ?? 'Failed to load scan history.';
    }

    notifyListeners();
  }

  /// Refresh history (used by pull-to-refresh)
  Future<void> refreshHistory() async {
    final response = await _historyService.fetchHistory();

    if (response.success && response.data != null) {
      _items = response.data!;
      if (_items.isEmpty) {
        _status = HistoryStatus.empty;
      } else {
        _status = HistoryStatus.loaded;
      }
      _errorMessage = null;
    } else {
      // If a refresh fails, keep current items but notify error
      _errorMessage = response.message ?? 'Failed to refresh scan history.';
    }

    notifyListeners();
  }

  /// Delete a history item by ID
  Future<bool> deleteItem(int id) async {
    _deletingItemId = id;
    notifyListeners();

    final response = await _historyService.deleteHistoryItem(id);

    _deletingItemId = null;

    if (response.success) {
      _items.removeWhere((item) => item.id == id);
      if (_items.isEmpty) {
        _status = HistoryStatus.empty;
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to delete history item.';
      notifyListeners();
      return false;
    }
  }
}
