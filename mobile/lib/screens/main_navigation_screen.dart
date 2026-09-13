import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/share_intent_service.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'text_scanner_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  StreamSubscription<String>? _shareSubscription;
  final ShareIntentService _shareService = ShareIntentService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initSharedTextHandling();
  }

  void _initSharedTextHandling() {
    // 1. Check for shared text from cold launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialText = await _shareService.getInitialSharedText();
      if (initialText != null && initialText.isNotEmpty && mounted) {
        _navigateToTextScanner(initialText);
      }
    });

    // 2. Listen for shared text while app is active or in background
    _shareSubscription = _shareService.sharedTextStream.listen((sharedText) {
      if (sharedText.isNotEmpty && mounted) {
        _navigateToTextScanner(sharedText);
      }
    });
  }

  void _navigateToTextScanner(String sharedText) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TextScannerScreen(initialText: sharedText),
      ),
    );
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onTabSelected),
      const ScanScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: AppTheme.primary),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
