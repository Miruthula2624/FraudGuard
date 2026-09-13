import 'scan_result.dart';

class ScanHistoryItem {
  final int id;
  final int? userId;
  final String? originalContent;
  final String? extractedText;
  final String classification;
  final List<String> scamIndicators;
  final int confidenceScore;
  final String? filePath;
  final DateTime? createdAt;

  const ScanHistoryItem({
    required this.id,
    this.userId,
    this.originalContent,
    this.extractedText,
    required this.classification,
    required this.scamIndicators,
    required this.confidenceScore,
    this.filePath,
    this.createdAt,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    // Safely parse ID
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.round();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    // Safely parse confidence score
    int parseScore(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.round();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    // Parse scam indicators list (can be List or null)
    List<String> indicators = [];
    final rawIndicators = json['scam_indicators'];
    if (rawIndicators is List) {
      indicators = rawIndicators.map((e) => e.toString()).toList();
    } else if (rawIndicators is String && rawIndicators.isNotEmpty) {
      indicators = [rawIndicators];
    }

    // Parse DateTime safely
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at'].toString());
      } catch (_) {
        parsedDate = null;
      }
    }

    return ScanHistoryItem(
      id: parseId(json['id']),
      userId: json['user_id'] != null ? parseId(json['user_id']) : null,
      originalContent: json['original_content']?.toString(),
      extractedText: json['extracted_text']?.toString(),
      classification: json['classification']?.toString() ?? 'Unknown Classification',
      scamIndicators: indicators,
      confidenceScore: parseScore(json['confidence_score']),
      filePath: json['file_path']?.toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      if (originalContent != null) 'original_content': originalContent,
      if (extractedText != null) 'extracted_text': extractedText,
      'classification': classification,
      'scam_indicators': scamIndicators,
      'confidence_score': confidenceScore,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Converts this historical record into a ScanResult for opening in the existing Result UI.
  ScanResult toScanResult() {
    return ScanResult(
      classification: classification,
      confidenceScore: confidenceScore,
      indicators: scamIndicators,
      extractedText: extractedText ?? originalContent,
      contentType: filePath != null ? 'file' : 'text',
      contentTypeLabel: filePath != null ? 'Image / Document' : 'Text Content',
    );
  }
}
