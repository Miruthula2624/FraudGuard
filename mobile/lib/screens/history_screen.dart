import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_history.dart';
import '../providers/history_provider.dart';
import 'scan_result_screen.dart';
import 'text_scanner_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch history on initial entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).fetchHistory();
    });
  }

  void _confirmDelete(ScanHistoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Scan Record'),
        content: const Text(
          'Delete this scan from your history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.riskHigh,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await Provider.of<HistoryProvider>(context, listen: false)
          .deleteItem(item.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan record deleted successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openHistoricalResult(ScanHistoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          scanResult: item.toScanResult(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: SafeArea(
        child: _buildBody(context, historyProvider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryProvider provider) {
    // 1. Loading State
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Loading scan records...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (provider.hasError && provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: AppTheme.riskHigh,
              ),
              const SizedBox(height: 16),
              Text(
                'Could Not Load History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage ?? 'An error occurred.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => provider.fetchHistory(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (provider.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  size: 44,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Scans Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your previous scan results will appear here. Start your first scan to analyze job postings, messages, or emails for threats.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const TextScannerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Start a Scan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Loaded State with Pull-To-Refresh
    final items = provider.items;

    return RefreshIndicator(
      onRefresh: () => provider.refreshHistory(),
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: items.length + 1, // +1 for header intro
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Review your previous scam detection results.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                  ),
                  Text(
                    '${items.length} ${items.length == 1 ? "Record" : "Records"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final item = items[index - 1];
          return _buildHistoryCard(context, item, provider);
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ScanHistoryItem item,
    HistoryProvider provider,
  ) {
    final isScam = _isScamClassification(item.classification);
    final isGenuine = _isGenuineClassification(item.classification);

    final riskColor = isScam
        ? AppTheme.riskHigh
        : isGenuine
            ? AppTheme.riskLow
            : AppTheme.riskModerate;

    final riskIcon = isScam
        ? Icons.warning_amber_rounded
        : isGenuine
            ? Icons.verified_user_outlined
            : Icons.info_outline;

    final isDeleting = provider.deletingItemId == item.id;

    // Truncated preview text
    final previewText = item.extractedText?.trim().isNotEmpty == true
        ? item.extractedText!.trim()
        : (item.originalContent?.trim().isNotEmpty == true
            ? item.originalContent!.trim()
            : 'No content text recorded');

    final formattedDate = _formatDate(item.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isDeleting ? null : () => _openHistoricalResult(item),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Classification Chip + Delete Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(riskIcon, size: 16, color: riskColor),
                        const SizedBox(width: 6),
                        Text(
                          item.classification.split(' / ')[0],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Threat Confidence Badge
                  Text(
                    '${item.confidenceScore}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete Button
                  if (isDeleting)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.grey.shade600,
                      tooltip: 'Delete Record',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDelete(item),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Content Preview snippet (max 2 lines with ellipsis)
              Text(
                previewText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Row: Date & Content Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        item.filePath != null
                            ? Icons.image_outlined
                            : Icons.article_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.filePath != null ? 'Image Scan' : 'Text Scan',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isScamClassification(String classification) {
    final lower = classification.toLowerCase();
    return lower.contains('scam') || lower.contains('fake');
  }

  bool _isGenuineClassification(String classification) {
    final lower = classification.toLowerCase();
    return lower.contains('genuine') || lower.contains('legitimate');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day · $hour:$minute';
  }
}
