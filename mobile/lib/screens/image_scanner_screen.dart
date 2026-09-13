import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/scan_provider.dart';
import '../services/image_picker_helper.dart';
import 'scan_result_screen.dart';

class ImageScannerScreen extends StatefulWidget {
  const ImageScannerScreen({super.key});

  @override
  State<ImageScannerScreen> createState() => _ImageScannerScreenState();
}

class _ImageScannerScreenState extends State<ImageScannerScreen> {
  final ImagePickerHelper _pickerHelper = ImagePickerHelper();
  File? _selectedImage;

  void _pickImage(bool fromCamera) async {
    final image = fromCamera
        ? await _pickerHelper.captureFromCamera()
        : await _pickerHelper.pickFromGallery();

    if (image != null && mounted) {
      setState(() {
        _selectedImage = image;
      });
      Provider.of<ScanProvider>(context, listen: false).clearResult();
    }
  }

  void _onScanPressed() async {
    if (_selectedImage == null) return;

    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final success = await scanProvider.scanImage(_selectedImage!);
    if (success && mounted && scanProvider.scanResult != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            scanResult: scanProvider.scanResult!,
            onScanAgain: () {
              setState(() {
                _selectedImage = null;
              });
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
        title: const Text('Scan Image / Offer Letter'),
        actions: [
          if (_selectedImage != null || scanResult != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Scanner',
              onPressed: isScanning
                  ? null
                  : () {
                      setState(() {
                        _selectedImage = null;
                      });
                      scanProvider.clearResult();
                    },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload a screenshot of an offer letter, chat message, or email. FraudGuard will extract the text via OCR and analyze it.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Image Selection Options
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isScanning ? null : () => _pickImage(true),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Take Photo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isScanning ? null : () => _pickImage(false),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('From Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Image Preview Area
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No image selected yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Scan Action Button
              ElevatedButton.icon(
                onPressed: (isScanning || _selectedImage == null) ? null : _onScanPressed,
                icon: isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.document_scanner_outlined),
                label: Text(
                  isScanning ? 'Uploading & Running OCR...' : 'Scan Image with OCR',
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
                  'OCR & Scan Result',
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
            _buildResultRow('OCR Extracted Length', '${result.extractedText?.length ?? 0} chars'),
            const SizedBox(height: 8),
            _buildResultRow('Indicators Found', '${result.indicators.length} signals detected'),
            const SizedBox(height: 8),
            _buildResultRow(
              'Explainable Analysis',
              result.explanation != null
                  ? 'Received (${result.explanation!.categories.length} categories)'
                  : 'Not provided',
            ),
            if (result.extractedText != null && result.extractedText!.isNotEmpty) ...[
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
                      'Extracted OCR Snippet:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.extractedText!.length > 150
                          ? '${result.extractedText!.substring(0, 150)}...'
                          : result.extractedText!,
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
