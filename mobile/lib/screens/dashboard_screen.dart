import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_history.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import 'history_screen.dart';
import 'image_scanner_screen.dart';
import 'scan_result_screen.dart';
import 'text_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      if (historyProvider.status == HistoryStatus.initial) {
        historyProvider.fetchHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FraudGuard Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: () => historyProvider.fetchHistory(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. GREETING / HEADER
              _buildGreetingHeader(user?.username ?? 'User'),
              const SizedBox(height: 20),

              // 2. SAFETY TIP BANNER
              _buildSafetyTipCard(),
              const SizedBox(height: 24),

              // 3. QUICK SCAN ACTIONS ("Check Something")
              _buildQuickScanSection(context),
              const SizedBox(height: 24),

              // 4. SECURITY OVERVIEW (Statistics derived from HistoryProvider)
              _buildSecurityOverviewSection(historyProvider),
              const SizedBox(height: 24),

              // 5. RECENT SCANS
              _buildRecentScansSection(context, historyProvider),
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

  Widget _buildGreetingHeader(String username) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppTheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $username',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your AI scam detection shield is active.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft Blue
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_outlined,
            color: Color(0xFF1D4ED8),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Safe Reminder',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Never send OTPs, passwords, or upfront payments to verify a job offer or claim an unverified prize.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF1E40AF),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check Something',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickScanButton(
                context,
                title: 'Scan Text',
                subtitle: 'Messages, emails, offers',
                icon: Icons.text_fields_outlined,
                color: AppTheme.primary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TextScannerScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickScanButton(
                context,
                title: 'Scan Image',
                subtitle: 'Screenshots & letters',
                icon: Icons.document_scanner_outlined,
                color: AppTheme.secondary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ImageScannerScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickScanButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOverviewSection(HistoryProvider historyProvider) {
    if (historyProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (historyProvider.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bar_chart, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Overview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'No scans yet. Run your first scan to generate statistics.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Derive actual statistics from loaded history items
    final items = historyProvider.items;
    final totalScans = items.length;
    int scamCount = 0;
    int suspiciousCount = 0;
    int genuineCount = 0;

    for (final item in items) {
      final cls = item.classification.toLowerCase();
      if (cls.contains('scam') || cls.contains('fake')) {
        scamCount++;
      } else if (cls.contains('suspicious')) {
        suspiciousCount++;
      } else if (cls.contains('genuine') || cls.contains('legitimate')) {
        genuineCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Total Scans',
                    value: '$totalScans',
                    color: AppTheme.primary,
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    label: 'Scams Flagged',
                    value: '$scamCount',
                    color: AppTheme.riskHigh,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Suspicious',
                    value: '$suspiciousCount',
                    color: AppTheme.riskModerate,
                    icon: Icons.help_outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    label: 'Genuine',
                    value: '$genuineCount',
                    color: AppTheme.riskLow,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScansSection(
    BuildContext context,
    HistoryProvider historyProvider,
  ) {
    if (historyProvider.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentItems = historyProvider.items.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Scans',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
            ),
            TextButton(
              onPressed: () {
                if (widget.onNavigateTab != null) {
                  widget.onNavigateTab!(2); // Switch to History Tab (index 2)
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                }
              },
              child: const Text('View All History'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentItems.map((item) => _buildRecentItemCard(context, item)),
      ],
    );
  }

  Widget _buildRecentItemCard(BuildContext context, ScanHistoryItem item) {
    final lowerCls = item.classification.toLowerCase();
    final isScam = lowerCls.contains('scam') || lowerCls.contains('fake');
    final isGenuine = lowerCls.contains('genuine') || lowerCls.contains('legitimate');

    final color = isScam
        ? AppTheme.riskHigh
        : isGenuine
            ? AppTheme.riskLow
            : AppTheme.riskModerate;

    final icon = isScam
        ? Icons.warning_amber_rounded
        : isGenuine
            ? Icons.verified_user_outlined
            : Icons.info_outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ScanResultScreen(
                scanResult: item.toScanResult(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.classification.split(' / ')[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.confidenceScore}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
