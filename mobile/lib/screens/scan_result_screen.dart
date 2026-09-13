import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';

class ScanResultScreen extends StatelessWidget {
  final ScanResult scanResult;
  final VoidCallback? onScanAgain;

  const ScanResultScreen({
    super.key,
    required this.scanResult,
    this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    final isScam = _isScamClassification(scanResult.classification);
    final isGenuine = _isGenuineClassification(scanResult.classification);

    final Color riskColor = isScam
        ? AppTheme.riskHigh
        : isGenuine
            ? AppTheme.riskLow
            : AppTheme.riskModerate;

    final IconData riskIcon = isScam
        ? Icons.warning_amber_rounded
        : isGenuine
            ? Icons.verified_user_outlined
            : Icons.info_outline;

    final String riskTitle = isScam
        ? 'High Risk Scam Detected'
        : isGenuine
            ? 'No Major Scam Indicators Detected'
            : 'Suspicious / Caution Advised';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HEADER & RISK SUMMARY BANNER
              _buildHeaderCard(context, riskColor, riskIcon, riskTitle),
              const SizedBox(height: 16),

              // 2. EXPLANATION SUMMARY
              if (scanResult.explanation != null &&
                  scanResult.explanation!.summary.isNotEmpty) ...[
                _buildSummaryCard(context, scanResult.explanation!.summary),
                const SizedBox(height: 16),
              ],

              // 3. OVERALL SAFETY ADVICE (High-priority callout)
              if (scanResult.explanation != null &&
                  scanResult.explanation!.overallAdvice.isNotEmpty) ...[
                _buildOverallAdviceCard(
                    context, scanResult.explanation!.overallAdvice),
                const SizedBox(height: 20),
              ],

              // 4. "WHY WAS THIS FLAGGED?" EXPLANATION CATEGORIES
              _buildWhyFlaggedSection(context),
              const SizedBox(height: 20),

              // 5. EXTRACTED OCR TEXT (if image scan)
              if (scanResult.extractedText != null &&
                  scanResult.extractedText!.trim().isNotEmpty) ...[
                _buildExtractedTextCard(context, scanResult.extractedText!),
                const SizedBox(height: 20),
              ],

              // 6. TECHNICAL & ML ASSESSMENT (Secondary)
              _buildTechnicalAssessmentCard(context),
              const SizedBox(height: 24),

              // 7. RESULT ACTIONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onScanAgain?.call();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WIDGET BUILDERS
  // ─────────────────────────────────────────────

  Widget _buildHeaderCard(
    BuildContext context,
    Color riskColor,
    IconData riskIcon,
    String riskTitle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(riskIcon, color: riskColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riskTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scanResult.classification,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: _buildMetricChip(
                  context,
                  label: 'Confidence Score',
                  value: '${scanResult.confidenceScore}%',
                  color: riskColor,
                ),
              ),
              if (scanResult.contentTypeLabel != null ||
                  scanResult.contentType != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: _buildMetricChip(
                    context,
                    label: 'Content Type',
                    value: scanResult.contentTypeLabel ??
                        scanResult.contentType!.toUpperCase(),
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String summary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined,
                  size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Executive Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallAdviceCard(BuildContext context, String advice) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Warm amber/yellow callout
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_rounded,
            color: Color(0xFFB45309),
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety Recommendation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  advice,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF78350F),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyFlaggedSection(BuildContext context) {
    final categories = scanResult.explanation?.categories ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why was this flagged?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Structured evidence and practical safety actions detected by FraudGuard',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        if (categories.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'No detailed explanation categories are available for this result.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...categories.map((cat) => _buildCategoryCard(context, cat)),
        ],
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, ExplanationCategory category) {
    final severityInfo = _getSeverityPresentation(category.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: severityInfo.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Header & Severity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: severityInfo.color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(severityInfo.icon, color: severityInfo.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: severityInfo.color,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: severityInfo.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.severity.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matched Evidence
                if (category.evidence.isNotEmpty) ...[
                  const Text(
                    'Evidence Found:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: category.evidence.map((evidenceItem) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          evidenceItem,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Why Suspicious
                if (category.whySuspicious.isNotEmpty) ...[
                  const Text(
                    'Why it matters:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.whySuspicious,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Recommended Action (What to do)
                if (category.recommendedAction.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'What you should do:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                category.recommendedAction,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedTextCard(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.document_scanner_outlined,
                  size: 20, color: AppTheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Extracted Text (OCR)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            constraints: const BoxConstraints(maxHeight: 180),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalAssessmentCard(BuildContext context) {
    final ml = scanResult.explanation?.mlAssessment;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.memory, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Technical Assessment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(
            'ML Assessment',
            ml != null
                ? '${ml.label.replaceAll('_', ' ')} (${ml.confidence}% confidence)'
                : (scanResult.mlUsed ? 'Online' : 'Rule-based only'),
          ),
          if (scanResult.ruleScore != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Rule Engine Score', '${scanResult.ruleScore}%'),
          ],
          if (scanResult.blendedScore != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Blended Score (60% ML + 40% Rule)',
                '${scanResult.blendedScore}%'),
          ],
          if (scanResult.indicators.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                'Raw Signals Detected', '${scanResult.indicators.length} indicators'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  CLASSIFICATION & SEVERITY HELPERS
  // ─────────────────────────────────────────────

  bool _isScamClassification(String classification) {
    final lower = classification.toLowerCase();
    return lower.contains('scam') || lower.contains('fake');
  }

  bool _isGenuineClassification(String classification) {
    final lower = classification.toLowerCase();
    return lower.contains('genuine') || lower.contains('legitimate');
  }

  _SeverityPresentation _getSeverityPresentation(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return _SeverityPresentation(
          color: const Color(0xFFDC2626), // Dark Red
          icon: Icons.error_rounded,
        );
      case 'HIGH':
        return _SeverityPresentation(
          color: const Color(0xFFEA580C), // Orange Red
          icon: Icons.warning_rounded,
        );
      case 'MEDIUM':
        return _SeverityPresentation(
          color: const Color(0xFFD97706), // Amber
          icon: Icons.info_rounded,
        );
      case 'LOW':
        return _SeverityPresentation(
          color: const Color(0xFF2563EB), // Blue
          icon: Icons.help_outline_rounded,
        );
      default:
        return _SeverityPresentation(
          color: AppTheme.riskNeutral,
          icon: Icons.circle_outlined,
        );
    }
  }
}

class _SeverityPresentation {
  final Color color;
  final IconData icon;

  const _SeverityPresentation({
    required this.color,
    required this.icon,
  });
}
