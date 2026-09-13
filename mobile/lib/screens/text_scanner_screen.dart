import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/scan_provider.dart';
import 'scan_result_screen.dart';

class TextScannerScreen extends StatefulWidget {
  final String? initialText;

  const TextScannerScreen({
    super.key,
    this.initialText,
  });

  @override
  State<TextScannerScreen> createState() => _TextScannerScreenState();
}

class _TextScannerScreenState extends State<TextScannerScreen> {
  late final TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onPastePressed() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();

      if (!mounted) return;

      if (text != null && text.isNotEmpty) {
        setState(() {
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text pasted from clipboard.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard is empty or contains no plain text.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to read from clipboard.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onScanPressed() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);

    final success = await scanProvider.scanText(_textController.text);
    if (success && mounted && scanProvider.scanResult != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            scanResult: scanProvider.scanResult!,
            onScanAgain: () {
              _textController.clear();
              scanProvider.clearResult();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    final isScanning = scanProvider.isScanning;
    final scanResult = scanProvider.scanResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Text Content'),
        actions: [
          if (scanResult != null || scanProvider.errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Scanner',
              onPressed: isScanning
                  ? null
                  : () {
                      _textController.clear();
                      scanProvider.clearResult();
                    },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Paste suspicious job postings, emails, or messages to analyze them for scam patterns.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Text Input Area
                TextFormField(
                  controller: _textController,
                  maxLines: 7,
                  minLines: 4,
                  enabled: !isScanning,
                  decoration: InputDecoration(
                    hintText: 'Enter or paste suspicious job description, WhatsApp message, or email here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter text to scan';
                    }
                    if (value.trim().length < 5) {
                      return 'Content must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Clipboard Import Convenience
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: isScanning ? null : _onPastePressed,
                    icon: const Icon(Icons.paste_rounded, size: 18),
                    label: const Text(
                      'Paste from Clipboard',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: isScanning ? null : _onScanPressed,
                  icon: isScanning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.shield_outlined),
                  label: Text(
                    isScanning ? 'Analyzing Content...' : 'Scan Content',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Error Display
                if (scanProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.riskHigh.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.riskHigh.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.riskHigh, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            scanProvider.errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.riskHigh,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Minimal Temporary Result Proof
                if (scanResult != null) _buildMinimalResultView(scanResult),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalResultView(ScanResult result) {
    final isScam = result.classification.toLowerCase().contains('scam') ||
        result.classification.toLowerCase().contains('fake');
    final badgeColor = isScam ? AppTheme.riskHigh : AppTheme.riskLow;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isScam ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: badgeColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Scan Result (Backend Verified)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildResultRow('Classification', result.classification),
            const SizedBox(height: 8),
            _buildResultRow('Confidence Score', '${result.confidenceScore}%'),
            const SizedBox(height: 8),
            _buildResultRow('Content Type', result.contentTypeLabel ?? result.contentType ?? 'Unknown'),
            const SizedBox(height: 8),
            _buildResultRow('ML Engine Used', result.mlUsed ? 'Yes (Confidence: ${result.mlConfidence ?? 'N/A'}%)' : 'Rule-based only'),
            const SizedBox(height: 8),
            _buildResultRow('Indicators Found', '${result.indicators.length} signals detected'),
            const SizedBox(height: 8),
            _buildResultRow(
              'Explainable Analysis',
              result.explanation != null
                  ? 'Received (${result.explanation!.categories.length} categories)'
                  : 'Not provided',
            ),
            if (result.explanation != null && result.explanation!.summary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Summary:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.explanation!.summary,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
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
}
