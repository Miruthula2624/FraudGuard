import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.initializing:
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppTheme.primary,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Restoring secure session...',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      case AuthStatus.authenticated:
        return const MainNavigationScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        return const LoginScreen();
    }
  }
}
