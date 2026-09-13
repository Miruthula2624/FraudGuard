import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 52,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.username ?? 'FraudGuard User',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Account & Security Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Account & Security',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildProfileRow('User ID', user?.id.toString() ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildProfileRow('Username', user?.username ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildProfileRow('Email', user?.email ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildProfileRow('Authentication', 'JWT Bearer Token'),
                      const SizedBox(height: 12),
                      _buildProfileRow('Token Storage', 'Encrypted Keystore/SharedPreferences'),
                      const SizedBox(height: 12),
                      _buildProfileRow('Target Host', ApiConstants.baseUrl),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // App Version Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.textSecondary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FraudGuard Mobile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version 1.0.0 (Production Ready)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sign Out Button
              ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                        'Are you sure you want to sign out of FraudGuard?',
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
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await authProvider.logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.riskHigh,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
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
