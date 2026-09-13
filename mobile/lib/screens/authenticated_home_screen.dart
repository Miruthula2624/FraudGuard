import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'history_screen.dart';
import 'image_scanner_screen.dart';
import 'text_scanner_screen.dart';

class AuthenticatedHomeScreen extends StatelessWidget {
  const AuthenticatedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FraudGuard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authProvider.logout();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.riskLow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppTheme.riskLow,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Authenticated Session Active',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back to FraudGuard Mobile',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),

              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'User Profile',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Full Name / Username', user?.username ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Email Address', user?.email ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow('User ID', user?.id.toString() ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Session Security Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security, color: AppTheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Session Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Auth Type', 'JWT Bearer Token'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Storage', 'Encrypted FlutterSecureStorage'),
                      const SizedBox(height: 12),
                      _buildInfoRow('API Target', ApiConstants.baseUrl),
                    ],
                  ),
                ),
              ),
              // Scanner Navigation Section
              Text(
                'Scam Detection Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TextScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.text_fields_outlined),
                      label: const Text('Scan Text'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ImageScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: const Text('Scan Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Scan History'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
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
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
