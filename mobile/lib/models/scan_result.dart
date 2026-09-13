class ExplanationCategory {
  final String category;
  final String severity; // CRITICAL, HIGH, MEDIUM, LOW
  final List<String> evidence;
  final String whySuspicious;
  final String recommendedAction;

  const ExplanationCategory({
    required this.category,
    required this.severity,
    required this.evidence,
    required this.whySuspicious,
    required this.recommendedAction,
  });

  factory ExplanationCategory.fromJson(Map<String, dynamic> json) {
    final rawEvidence = json['evidence'];
    List<String> evidenceList = [];
    if (rawEvidence is List) {
      evidenceList = rawEvidence.map((e) => e.toString()).toList();
    } else if (rawEvidence is String) {
      evidenceList = [rawEvidence];
    }

    return ExplanationCategory(
      category: json['category']?.toString() ?? 'General Indicator',
      severity: json['severity']?.toString() ?? 'MEDIUM',
      evidence: evidenceList,
      whySuspicious: json['whySuspicious']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'severity': severity,
      'evidence': evidence,
      'whySuspicious': whySuspicious,
      'recommendedAction': recommendedAction,
    };
  }
}

class MlAssessment {
  final String label;
  final num confidence;

  const MlAssessment({
    required this.label,
    required this.confidence,
  });

  factory MlAssessment.fromJson(Map<String, dynamic> json) {
    return MlAssessment(
      label: json['label']?.toString() ?? 'unknown',
      confidence: json['confidence'] is num
          ? json['confidence'] as num
          : num.tryParse(json['confidence'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
    };
  }
}

class ScamExplanation {
  final String summary;
  final List<ExplanationCategory> categories;
  final String overallAdvice;
  final MlAssessment? mlAssessment;

  const ScamExplanation({
    required this.summary,
    required this.categories,
    required this.overallAdvice,
    this.mlAssessment,
  });

  factory ScamExplanation.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    List<ExplanationCategory> categoriesList = [];
    if (rawCategories is List) {
      categoriesList = rawCategories
          .whereType<Map<String, dynamic>>()
          .map((c) => ExplanationCategory.fromJson(c))
          .toList();
    }

    MlAssessment? ml;
    if (json['mlAssessment'] is Map<String, dynamic>) {
      ml = MlAssessment.fromJson(json['mlAssessment'] as Map<String, dynamic>);
    }

    return ScamExplanation(
      summary: json['summary']?.toString() ?? '',
      categories: categoriesList,
      overallAdvice: json['overallAdvice']?.toString() ?? '',
      mlAssessment: ml,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'categories': categories.map((c) => c.toJson()).toList(),
      'overallAdvice': overallAdvice,
      if (mlAssessment != null) 'mlAssessment': mlAssessment!.toJson(),
    };
  }
}

class ScanResult {
  final String classification;
  final int confidenceScore;
  final List<String> indicators;
  final String? extractedText;
  final String? contentType;
  final String? contentTypeLabel;
  final String? companyName;
  final String? appLink;
  final bool isInvalidInput;
  final bool mlUsed;
  final String? mlLabel;
  final String? mlDisplay;
  final num? mlConfidence;
  final Map<String, dynamic>? mlProbabilities;
  final int? ruleScore;
  final int? blendedScore;
  final ScamExplanation? explanation;

  const ScanResult({
    required this.classification,
    required this.confidenceScore,
    required this.indicators,
    this.extractedText,
    this.contentType,
    this.contentTypeLabel,
    this.companyName,
    this.appLink,
    this.isInvalidInput = false,
    this.mlUsed = false,
    this.mlLabel,
    this.mlDisplay,
    this.mlConfidence,
    this.mlProbabilities,
    this.ruleScore,
    this.blendedScore,
    this.explanation,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final rawIndicators = json['indicators'];
    List<String> indicatorsList = [];
    if (rawIndicators is List) {
      indicatorsList = rawIndicators.map((i) => i.toString()).toList();
    }

    ScamExplanation? exp;
    if (json['explanation'] is Map<String, dynamic>) {
      exp = ScamExplanation.fromJson(json['explanation'] as Map<String, dynamic>);
    }

    int parseScore(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.round();
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    return ScanResult(
      classification: json['classification']?.toString() ?? 'Unknown',
      confidenceScore: parseScore(json['confidenceScore']),
      indicators: indicatorsList,
      extractedText: json['extractedText']?.toString(),
      contentType: json['contentType']?.toString(),
      contentTypeLabel: json['contentTypeLabel']?.toString(),
      companyName: json['companyName']?.toString(),
      appLink: json['appLink']?.toString(),
      isInvalidInput: json['isInvalidInput'] == true,
      mlUsed: json['mlUsed'] == true,
      mlLabel: json['mlLabel']?.toString(),
      mlDisplay: json['mlDisplay']?.toString(),
      mlConfidence: json['mlConfidence'] is num ? json['mlConfidence'] as num : null,
      mlProbabilities: json['mlProbabilities'] is Map<String, dynamic>
          ? json['mlProbabilities'] as Map<String, dynamic>
          : null,
      ruleScore: json['ruleScore'] != null ? parseScore(json['ruleScore']) : null,
      blendedScore: json['blendedScore'] != null ? parseScore(json['blendedScore']) : null,
      explanation: exp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classification': classification,
      'confidenceScore': confidenceScore,
      'indicators': indicators,
      if (extractedText != null) 'extractedText': extractedText,
      if (contentType != null) 'contentType': contentType,
      if (contentTypeLabel != null) 'contentTypeLabel': contentTypeLabel,
      if (companyName != null) 'companyName': companyName,
      if (appLink != null) 'appLink': appLink,
      'isInvalidInput': isInvalidInput,
      'mlUsed': mlUsed,
      if (mlLabel != null) 'mlLabel': mlLabel,
      if (mlDisplay != null) 'mlDisplay': mlDisplay,
      if (mlConfidence != null) 'mlConfidence': mlConfidence,
      if (mlProbabilities != null) 'mlProbabilities': mlProbabilities,
      if (ruleScore != null) 'ruleScore': ruleScore,
      if (blendedScore != null) 'blendedScore': blendedScore,
      if (explanation != null) 'explanation': explanation!.toJson(),
    };
  }
}
