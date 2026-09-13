import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/scan_history.dart';
import 'package:mobile/models/scan_result.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/history_provider.dart';
import 'package:mobile/providers/scan_provider.dart';
import 'package:mobile/screens/auth_gate.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/screens/history_screen.dart';
import 'package:mobile/screens/image_scanner_screen.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/main_navigation_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/register_screen.dart';
import 'package:mobile/screens/scan_result_screen.dart';
import 'package:mobile/screens/scan_screen.dart';
import 'package:mobile/screens/text_scanner_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/history_service.dart';
import 'package:mobile/services/scan_service.dart';
import 'package:provider/provider.dart';

// Mock AuthService for isolated widget testing
class MockAuthService extends AuthService {
  final User? initialUser;
  bool shouldLoginSucceed;
  bool shouldRegisterSucceed;

  MockAuthService({
    this.initialUser,
    this.shouldLoginSucceed = true,
    this.shouldRegisterSucceed = true,
  });

  @override
  Future<User?> restoreSession() async {
    return initialUser;
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    if (shouldLoginSucceed) {
      return AuthResult(
        success: true,
        user: const User(id: 42, username: 'Test User', email: 'test@example.com'),
        token: 'mock_jwt_token',
      );
    } else {
      return const AuthResult(
        success: false,
        message: 'Invalid credentials',
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String fullname,
    required String email,
    required String password,
  }) async {
    if (shouldRegisterSucceed) {
      return const AuthResult(
        success: true,
        message: 'Registration successful',
      );
    } else {
      return const AuthResult(
        success: false,
        message: 'Email already registered',
      );
    }
  }

  @override
  Future<void> logout() async {}
}

// Mock ScanService for isolated scanner testing
class MockScanService extends ScanService {
  bool shouldScanSucceed;
  String? customErrorMessage;

  MockScanService({
    this.shouldScanSucceed = true,
    this.customErrorMessage,
  });

  @override
  Future<ScanApiResponse> scanText(String content) async {
    if (!shouldScanSucceed) {
      return ScanApiResponse(
        success: false,
        message: customErrorMessage ?? 'Scan text failed.',
      );
    }

    return const ScanApiResponse(
      success: true,
      result: ScanResult(
        classification: '❌ Fake Job / Scam',
        confidenceScore: 88,
        indicators: [
          '🚨 Payment demanded for registration',
          '🤖 ML Model (fake job): 92% confidence'
        ],
        extractedText: 'Urgent hiring! Pay Rs 500 registration fee to secure your laptop.',
        contentType: 'job',
        contentTypeLabel: 'Job Posting',
        mlUsed: true,
        mlLabel: 'fake_job',
        mlConfidence: 92,
        ruleScore: 80,
        blendedScore: 88,
        explanation: ScamExplanation(
          summary: 'This content contains multiple indicators commonly associated with fraudulent activity. Review the evidence below before taking any action.',
          categories: [
            ExplanationCategory(
              category: 'Payment Demand / Upfront Fee',
              severity: 'CRITICAL',
              evidence: ['Pay Rs 500 registration fee'],
              whySuspicious: 'Legitimate employers never demand upfront fees from candidates.',
              recommendedAction: 'Do not pay any money to secure a job.',
            ),
          ],
          overallAdvice: 'Do not send money, wire funds, or pay recruitment fees.',
          mlAssessment: MlAssessment(label: 'fake_job', confidence: 92),
        ),
      ),
    );
  }

  @override
  Future<ScanApiResponse> scanImage(File imageFile) async {
    if (!shouldScanSucceed) {
      return ScanApiResponse(
        success: false,
        message: customErrorMessage ?? 'Scan image failed.',
      );
    }

    return const ScanApiResponse(
      success: true,
      result: ScanResult(
        classification: '❌ Scam Mail',
        confidenceScore: 90,
        indicators: ['🔗 Shortened URL detected'],
        extractedText: 'Congratulations! You won the lottery. Claim at bit.ly/prize',
        contentType: 'email',
        contentTypeLabel: 'Email',
        explanation: ScamExplanation(
          summary: 'Lottery scam detected in email image.',
          categories: [
            ExplanationCategory(
              category: 'Lottery / Prize Scam',
              severity: 'HIGH',
              evidence: ['lottery', 'bit.ly/prize'],
              whySuspicious: 'Unsolicited lottery winnings requiring fee payments are fraudulent.',
              recommendedAction: 'Do not click links or wire processing fees.',
            ),
          ],
          overallAdvice: 'Do not pay fees to claim prizes.',
        ),
      ),
    );
  }
}

// Mock HistoryService for isolated history testing
class MockHistoryService extends HistoryService {
  bool shouldFetchSucceed;
  bool shouldDeleteSucceed;
  List<ScanHistoryItem> mockItems;
  String? customErrorMessage;

  MockHistoryService({
    this.shouldFetchSucceed = true,
    this.shouldDeleteSucceed = true,
    List<ScanHistoryItem>? items,
    this.customErrorMessage,
  }) : mockItems = items ?? [];

  @override
  Future<HistoryApiResponse<List<ScanHistoryItem>>> fetchHistory() async {
    if (!shouldFetchSucceed) {
      return HistoryApiResponse(
        success: false,
        message: customErrorMessage ?? 'Failed to retrieve scan history.',
      );
    }
    return HistoryApiResponse(
      success: true,
      data: List.from(mockItems),
    );
  }

  @override
  Future<HistoryApiResponse<void>> deleteHistoryItem(int id) async {
    if (!shouldDeleteSucceed) {
      return HistoryApiResponse(
        success: false,
        message: customErrorMessage ?? 'Failed to delete history item.',
      );
    }
    mockItems.removeWhere((item) => item.id == id);
    return const HistoryApiResponse(
      success: true,
      message: 'History item deleted',
    );
  }
}

void main() {
  group('User Model Tests', () {
    test('User serialization and deserialization', () {
      final json = {
        'id': 1,
        'username': 'Alex Hunter',
        'email': 'alex@example.com',
      };
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.username, 'Alex Hunter');
      expect(user.email, 'alex@example.com');
      expect(user.toJson(), json);
    });

    test('User equality and parsing string ID safely', () {
      final json = {
        'id': '99',
        'username': 'Sam',
        'email': 'sam@example.com',
      };
      final user = User.fromJson(json);
      expect(user.id, 99);
      expect(user == const User(id: 99, username: 'Sam', email: 'sam@example.com'), isTrue);
    });
  });

  group('Scan Result Model Tests', () {
    test('Parse normal scan response with full explanation', () {
      final json = {
        'classification': '❌ Fake Job / Scam',
        'confidenceScore': 85,
        'indicators': ['Upfront fee demanded', 'Free email domain used'],
        'extractedText': 'Pay registration fee to hr@gmail.com',
        'contentType': 'job',
        'contentTypeLabel': 'Job Posting',
        'mlUsed': true,
        'mlLabel': 'fake_job',
        'mlConfidence': 90,
        'ruleScore': 75,
        'blendedScore': 85,
        'explanation': {
          'summary': 'Fraudulent job indicators detected.',
          'categories': [
            {
              'category': 'Payment Demand / Upfront Fee',
              'severity': 'CRITICAL',
              'evidence': ['registration fee'],
              'whySuspicious': 'Upfront fees are standard scam tactics.',
              'recommendedAction': 'Do not transfer funds.'
            }
          ],
          'overallAdvice': 'Never pay to get hired.',
          'mlAssessment': {
            'label': 'fake_job',
            'confidence': 90
          }
        }
      };

      final result = ScanResult.fromJson(json);
      expect(result.classification, '❌ Fake Job / Scam');
      expect(result.confidenceScore, 85);
      expect(result.indicators.length, 2);
      expect(result.mlUsed, isTrue);
      expect(result.explanation, isNotNull);
      expect(result.explanation!.summary, 'Fraudulent job indicators detected.');
      expect(result.explanation!.categories.length, 1);
      expect(result.explanation!.categories[0].category, 'Payment Demand / Upfront Fee');
      expect(result.explanation!.categories[0].severity, 'CRITICAL');
      expect(result.explanation!.mlAssessment?.label, 'fake_job');
      expect(result.explanation!.mlAssessment?.confidence, 90);
    });

    test('Handle missing optional fields safely in ScanResult', () {
      final json = {
        'classification': '✅ Genuine Job',
        'confidenceScore': 10,
        'indicators': [],
      };

      final result = ScanResult.fromJson(json);
      expect(result.classification, '✅ Genuine Job');
      expect(result.confidenceScore, 10);
      expect(result.indicators, isEmpty);
      expect(result.extractedText, isNull);
      expect(result.explanation, isNull);
      expect(result.mlUsed, isFalse);
    });
  });

  group('ScanProvider Tests', () {
    test('Initial state is idle', () {
      final provider = ScanProvider(scanService: MockScanService());
      expect(provider.status, ScanStatus.idle);
      expect(provider.isScanning, isFalse);
      expect(provider.hasResult, isFalse);
      expect(provider.scanResult, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('Successful text scan updates status and result', () async {
      final provider = ScanProvider(scanService: MockScanService());
      final success = await provider.scanText('Suspicious job text');

      expect(success, isTrue);
      expect(provider.status, ScanStatus.success);
      expect(provider.hasResult, isTrue);
      expect(provider.scanResult?.classification, '❌ Fake Job / Scam');
      expect(provider.errorMessage, isNull);
    });

    test('Failed text scan sets error status and message', () async {
      final provider = ScanProvider(
        scanService: MockScanService(shouldScanSucceed: false, customErrorMessage: 'Backend offline'),
      );
      final success = await provider.scanText('Some text');

      expect(success, isFalse);
      expect(provider.status, ScanStatus.error);
      expect(provider.hasResult, isFalse);
      expect(provider.errorMessage, 'Backend offline');
    });

    test('clearResult resets state to idle', () async {
      final provider = ScanProvider(scanService: MockScanService());
      await provider.scanText('Suspicious job text');
      expect(provider.hasResult, isTrue);

      provider.clearResult();
      expect(provider.status, ScanStatus.idle);
      expect(provider.scanResult, isNull);
      expect(provider.errorMessage, isNull);
    });
  });

  group('History Model Tests', () {
    test('History model parses valid backend data and converts to ScanResult', () {
      final json = {
        'id': 101,
        'user_id': 5,
        'original_content': 'Work from home Rs 50000 daily',
        'extracted_text': 'Work from home Rs 50000 daily',
        'classification': '❌ Fake Job / Scam',
        'scam_indicators': ['🚨 High salary promise', '🤖 ML Model: 95%'],
        'confidence_score': 95,
        'file_path': '172578-offer.jpg',
        'created_at': '2026-09-08T10:00:00.000Z',
      };

      final item = ScanHistoryItem.fromJson(json);
      expect(item.id, 101);
      expect(item.userId, 5);
      expect(item.classification, '❌ Fake Job / Scam');
      expect(item.scamIndicators.length, 2);
      expect(item.confidenceScore, 95);
      expect(item.filePath, '172578-offer.jpg');
      expect(item.createdAt, isNotNull);

      final scanResult = item.toScanResult();
      expect(scanResult.classification, '❌ Fake Job / Scam');
      expect(scanResult.confidenceScore, 95);
      expect(scanResult.extractedText, 'Work from home Rs 50000 daily');
      expect(scanResult.contentTypeLabel, 'Image / Document');
    });

    test('History model handles nullable/missing fields safely', () {
      final json = {
        'id': '202',
        'classification': '✅ Genuine Job',
        'confidence_score': '15',
      };

      final item = ScanHistoryItem.fromJson(json);
      expect(item.id, 202);
      expect(item.userId, isNull);
      expect(item.originalContent, isNull);
      expect(item.extractedText, isNull);
      expect(item.scamIndicators, isEmpty);
      expect(item.confidenceScore, 15);
      expect(item.filePath, isNull);
      expect(item.createdAt, isNull);
    });
  });

  group('HistoryProvider Tests', () {
    test('Initial state is initial', () {
      final provider = HistoryProvider(historyService: MockHistoryService());
      expect(provider.status, HistoryStatus.initial);
      expect(provider.items, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('Successful fetch sets loaded state with items', () async {
      final mockItem = ScanHistoryItem(
        id: 1,
        classification: '❌ Scam Message',
        scamIndicators: ['OTP phishing'],
        confidenceScore: 92,
        extractedText: 'Share your OTP immediately',
        createdAt: DateTime.now(),
      );

      final provider = HistoryProvider(
        historyService: MockHistoryService(items: [mockItem]),
      );

      await provider.fetchHistory();
      expect(provider.status, HistoryStatus.loaded);
      expect(provider.items.length, 1);
      expect(provider.items.first.id, 1);
      expect(provider.isEmpty, isFalse);
    });

    test('Empty fetch sets empty state', () async {
      final provider = HistoryProvider(
        historyService: MockHistoryService(items: []),
      );

      await provider.fetchHistory();
      expect(provider.status, HistoryStatus.empty);
      expect(provider.isEmpty, isTrue);
      expect(provider.items, isEmpty);
    });

    test('Error during fetch sets error state', () async {
      final provider = HistoryProvider(
        historyService: MockHistoryService(
          shouldFetchSucceed: false,
          customErrorMessage: 'Server connection error',
        ),
      );

      await provider.fetchHistory();
      expect(provider.status, HistoryStatus.error);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, 'Server connection error');
    });

    test('Delete operation removes item from local history', () async {
      final item1 = ScanHistoryItem(
        id: 1,
        classification: '❌ Scam Mail',
        scamIndicators: [],
        confidenceScore: 80,
      );
      final item2 = ScanHistoryItem(
        id: 2,
        classification: '✅ Genuine Job',
        scamIndicators: [],
        confidenceScore: 10,
      );

      final provider = HistoryProvider(
        historyService: MockHistoryService(items: [item1, item2]),
      );

      await provider.fetchHistory();
      expect(provider.items.length, 2);

      final deleteSuccess = await provider.deleteItem(1);
      expect(deleteSuccess, isTrue);
      expect(provider.items.length, 1);
      expect(provider.items.first.id, 2);
    });
  });

  group('Auth Routing & Flow Tests', () {
    testWidgets('Unauthenticated user routes to LoginScreen', (WidgetTester tester) async {
      final mockAuthService = MockAuthService(initialUser: null);
      final authProvider = AuthProvider(authService: mockAuthService);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sign in to access your scam detection scanner'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Authenticated user routes to MainNavigationScreen and DashboardScreen', (WidgetTester tester) async {
      const user = User(id: 10, username: 'Verified Agent', email: 'agent@fraudguard.io');
      final mockAuthService = MockAuthService(initialUser: user);
      final authProvider = AuthProvider(authService: mockAuthService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<HistoryProvider>(
              create: (_) => HistoryProvider(historyService: MockHistoryService(items: [])),
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Welcome, Verified Agent'), findsOneWidget);
      expect(find.text('Scan Text'), findsOneWidget);
      expect(find.text('Scan Image'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Navigation to RegisterScreen works', (WidgetTester tester) async {
      final mockAuthService = MockAuthService(initialUser: null);
      final authProvider = AuthProvider(authService: mockAuthService);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Join FraudGuard'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('Logout action resets state to unauthenticated', (WidgetTester tester) async {
      const user = User(id: 10, username: 'Verified Agent', email: 'agent@fraudguard.io');
      final mockAuthService = MockAuthService(initialUser: user);
      final authProvider = AuthProvider(authService: mockAuthService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<HistoryProvider>(
              create: (_) => HistoryProvider(historyService: MockHistoryService(items: [])),
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      await authProvider.logout();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(authProvider.currentUser, isNull);
    });
  });

  group('Scanner UI & Navigation Tests', () {
    testWidgets('TextScannerScreen validates empty input', (WidgetTester tester) async {
      final scanProvider = ScanProvider(scanService: MockScanService());

      await tester.pumpWidget(
        ChangeNotifierProvider<ScanProvider>.value(
          value: scanProvider,
          child: const MaterialApp(
            home: TextScannerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Scan Content'));
      await tester.pump();

      expect(find.text('Please enter text to scan'), findsOneWidget);
    });

    testWidgets('TextScannerScreen navigates to ScanResultScreen on success', (WidgetTester tester) async {
      final scanProvider = ScanProvider(scanService: MockScanService());

      await tester.pumpWidget(
        ChangeNotifierProvider<ScanProvider>.value(
          value: scanProvider,
          child: const MaterialApp(
            home: TextScannerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'Urgent hiring! Pay registration fee to secure your position.',
      );
      await tester.pump();

      await tester.tap(find.text('Scan Content'));
      await tester.pumpAndSettle();

      // Navigated to ScanResultScreen
      expect(find.byType(ScanResultScreen), findsOneWidget);
      expect(find.text('Analysis Report'), findsOneWidget);
      expect(find.text('High Risk Scam Detected'), findsOneWidget);
      expect(find.text('❌ Fake Job / Scam'), findsOneWidget);
      expect(find.text('88%'), findsWidgets);
      expect(find.text('Why was this flagged?'), findsOneWidget);
      expect(find.text('Payment Demand / Upfront Fee'), findsOneWidget);
    });

    testWidgets('Step 10B: TextScannerScreen populates initialText and allows editing', (WidgetTester tester) async {
      final scanProvider = ScanProvider(scanService: MockScanService());
      const importedText = 'Suspicious offer imported from external share or clipboard';

      await tester.pumpWidget(
        ChangeNotifierProvider<ScanProvider>.value(
          value: scanProvider,
          child: const MaterialApp(
            home: TextScannerScreen(initialText: importedText),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify text is pre-filled
      expect(find.text(importedText), findsOneWidget);
      expect(find.text('Paste from Clipboard'), findsOneWidget);

      // Verify user can edit the prefilled text
      await tester.enterText(
        find.byType(TextFormField),
        'Modified text for review before scanning',
      );
      await tester.pump();
      expect(find.text('Modified text for review before scanning'), findsOneWidget);
    });

    testWidgets('Step 10B: Paste from Clipboard populates text when clipboard contains content', (WidgetTester tester) async {
      final scanProvider = ScanProvider(scanService: MockScanService());

      // Set clipboard content using standard Flutter test binding
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'Clipboard copied job listing text'};
        }
        return null;
      });

      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<ScanProvider>.value(
          value: scanProvider,
          child: const MaterialApp(
            home: TextScannerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final pasteButton = find.widgetWithText(TextButton, 'Paste from Clipboard');
      expect(pasteButton, findsOneWidget);
      await tester.tap(pasteButton);
      await tester.pumpAndSettle();

      expect(find.text('Clipboard copied job listing text'), findsOneWidget);
      expect(find.text('Text pasted from clipboard.'), findsOneWidget);
    });

    testWidgets('ImageScannerScreen displays camera and gallery actions', (WidgetTester tester) async {
      final scanProvider = ScanProvider(scanService: MockScanService());

      await tester.pumpWidget(
        ChangeNotifierProvider<ScanProvider>.value(
          value: scanProvider,
          child: const MaterialApp(
            home: ImageScannerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('From Gallery'), findsOneWidget);
      expect(find.text('No image selected yet'), findsOneWidget);
      expect(find.text('Scan Image with OCR'), findsOneWidget);
    });
  });

  group('Explainable ScanResultScreen UI Tests', () {
    testWidgets('Displays all explanation sections for scam result', (WidgetTester tester) async {
      const result = ScanResult(
        classification: '❌ Fake Job / Scam',
        confidenceScore: 95,
        indicators: ['Upfront fee demanded', 'Free email used'],
        extractedText: 'Urgent recruitment. Pay ₹1000 kit fee to hr@gmail.com. Visit bit.ly/hire',
        contentType: 'job',
        contentTypeLabel: 'Job Offer',
        mlUsed: true,
        ruleScore: 90,
        blendedScore: 95,
        explanation: ScamExplanation(
          summary: 'Multiple high-risk scam indicators detected in this job offer.',
          categories: [
            ExplanationCategory(
              category: 'Upfront Fee Demand',
              severity: 'CRITICAL',
              evidence: ['₹1000 kit fee'],
              whySuspicious: 'Legitimate employers never charge candidates for job equipment.',
              recommendedAction: 'Do not send any funds or wire transfers.',
            ),
            ExplanationCategory(
              category: 'Suspicious Recruiter Domain',
              severity: 'MEDIUM',
              evidence: ['hr@gmail.com'],
              whySuspicious: 'Free webmail addresses can be created anonymously.',
              recommendedAction: 'Verify recruiter identity with official corporate HR.',
            ),
          ],
          overallAdvice: 'Do not pay any money. Independently verify the employer.',
          mlAssessment: MlAssessment(label: 'fake_job', confidence: 98),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanResultScreen(scanResult: result),
        ),
      );

      await tester.pumpAndSettle();

      // Header checks
      expect(find.text('Analysis Report'), findsOneWidget);
      expect(find.text('High Risk Scam Detected'), findsOneWidget);
      expect(find.text('❌ Fake Job / Scam'), findsOneWidget);
      expect(find.text('95%'), findsWidgets);
      expect(find.text('Job Offer'), findsOneWidget);

      // Summary checks
      expect(find.text('Executive Summary'), findsOneWidget);
      expect(find.text('Multiple high-risk scam indicators detected in this job offer.'), findsOneWidget);

      // Safety recommendation checks
      expect(find.text('Safety Recommendation'), findsOneWidget);
      expect(find.text('Do not pay any money. Independently verify the employer.'), findsOneWidget);

      // Categories and evidence checks
      expect(find.text('Why was this flagged?'), findsOneWidget);
      expect(find.text('Upfront Fee Demand'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('₹1000 kit fee'), findsOneWidget);
      expect(find.text('Legitimate employers never charge candidates for job equipment.'), findsOneWidget);
      expect(find.text('Do not send any funds or wire transfers.'), findsOneWidget);

      expect(find.text('Suspicious Recruiter Domain'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('hr@gmail.com'), findsOneWidget);

      // Extracted OCR text checks
      expect(find.text('Extracted Text (OCR)'), findsOneWidget);
      expect(find.text('Urgent recruitment. Pay ₹1000 kit fee to hr@gmail.com. Visit bit.ly/hire'), findsOneWidget);

      // Technical ML Assessment checks
      expect(find.text('Technical Assessment'), findsOneWidget);
      expect(find.text('fake job (98% confidence)'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Blended Score (60% ML + 40% Rule)'), findsOneWidget);

      // Buttons
      expect(find.widgetWithText(OutlinedButton, 'Back'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Scan Again'), findsOneWidget);
    });

    testWidgets('Genuine / Low-Risk result renders safely with cautious guidance', (WidgetTester tester) async {
      const genuineResult = ScanResult(
        classification: '✅ Genuine Job',
        confidenceScore: 12,
        indicators: ['Official corporate portal link'],
        contentType: 'job',
        contentTypeLabel: 'Job Posting',
        explanation: ScamExplanation(
          summary: 'No major scam indicators were detected by the current detection system.',
          categories: [],
          overallAdvice: 'Continue to verify important job offers through official company channels.',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanResultScreen(scanResult: genuineResult),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Major Scam Indicators Detected'), findsOneWidget);
      expect(find.text('✅ Genuine Job'), findsOneWidget);
      expect(find.text('12%'), findsOneWidget);
      expect(find.text('No detailed explanation categories are available for this result.'), findsOneWidget);
      expect(find.text('Continue to verify important job offers through official company channels.'), findsOneWidget);
    });

    testWidgets('Missing explanation does not crash and renders graceful fallback', (WidgetTester tester) async {
      const bareResult = ScanResult(
        classification: '⚠️ Suspicious Job Post',
        confidenceScore: 45,
        indicators: ['Unrealistic salary offer'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanResultScreen(scanResult: bareResult),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Suspicious / Caution Advised'), findsOneWidget);
      expect(find.text('⚠️ Suspicious Job Post'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(find.text('No detailed explanation categories are available for this result.'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Scan Again'), findsOneWidget);
    });
  });

  group('History Screen UI Tests', () {
    testWidgets('HistoryScreen displays empty state and Start a Scan button', (WidgetTester tester) async {
      final historyProvider = HistoryProvider(
        historyService: MockHistoryService(items: []),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>.value(
          value: historyProvider,
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Scan History'), findsOneWidget);
      expect(find.text('No Scans Yet'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Start a Scan'), findsOneWidget);
    });

    testWidgets('HistoryScreen displays items and opens delete confirmation', (WidgetTester tester) async {
      final item = ScanHistoryItem(
        id: 10,
        classification: '❌ Scam Mail',
        confidenceScore: 94,
        extractedText: 'Lottery award won claim now at bit.ly/prize',
        scamIndicators: ['Shortened link', 'Lottery pattern'],
        createdAt: DateTime.now(),
      );

      final historyProvider = HistoryProvider(
        historyService: MockHistoryService(items: [item]),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>.value(
          value: historyProvider,
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Scan History'), findsOneWidget);
      expect(find.text('❌ Scam Mail'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('Lottery award won claim now at bit.ly/prize'), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Delete confirmation dialog appeared
      expect(find.text('Delete Scan Record'), findsOneWidget);
      expect(find.text('Delete this scan from your history? This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Delete'), findsOneWidget);

      // Tap Delete in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Empty state reached after deletion
      expect(find.text('No Scans Yet'), findsOneWidget);
    });

    testWidgets('Tapping a history item opens historical ScanResultScreen', (WidgetTester tester) async {
      final item = ScanHistoryItem(
        id: 20,
        classification: '❌ Fake Job / Scam',
        confidenceScore: 89,
        extractedText: 'Pay 500 registration fee for remote typing job',
        scamIndicators: ['Registration fee demanded'],
        createdAt: DateTime.now(),
      );

      final historyProvider = HistoryProvider(
        historyService: MockHistoryService(items: [item]),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<HistoryProvider>.value(
          value: historyProvider,
          child: const MaterialApp(
            home: HistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the history card
      await tester.tap(find.text('Pay 500 registration fee for remote typing job'));
      await tester.pumpAndSettle();

      // Reused ScanResultScreen opened
      expect(find.byType(ScanResultScreen), findsOneWidget);
      expect(find.text('Analysis Report'), findsOneWidget);
      expect(find.text('❌ Fake Job / Scam'), findsOneWidget);
      expect(find.text('89%'), findsWidgets);
    });
  });

  group('Dashboard & Bottom Navigation Tests', () {
    testWidgets('MainNavigationScreen renders with four bottom navigation tabs', (WidgetTester tester) async {
      const user = User(id: 1, username: 'Elena Fisher', email: 'elena@example.com');
      final authProvider = AuthProvider(authService: MockAuthService(initialUser: user));
      final historyProvider = HistoryProvider(historyService: MockHistoryService(items: []));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigation bar destinations exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Default selected tab is DashboardScreen
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Welcome, Elena Fisher'), findsOneWidget);
    });

    testWidgets('Bottom navigation switches between tabs correctly', (WidgetTester tester) async {
      const user = User(id: 1, username: 'Elena Fisher', email: 'elena@example.com');
      final authProvider = AuthProvider(authService: MockAuthService(initialUser: user));
      final historyProvider = HistoryProvider(historyService: MockHistoryService(items: []));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Scan tab (index 1)
      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();
      expect(find.byType(ScanScreen), findsOneWidget);
      expect(find.text('Choose Detection Mode'), findsOneWidget);

      // Switch to History tab (index 2)
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('No Scans Yet'), findsOneWidget);

      // Switch to Profile tab (index 3)
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Elena Fisher'), findsWidgets);
      expect(find.text('elena@example.com'), findsWidgets);
    });

    testWidgets('Dashboard derives statistics and displays recent scans', (WidgetTester tester) async {
      const user = User(id: 1, username: 'Elena Fisher', email: 'elena@example.com');
      final authProvider = AuthProvider(authService: MockAuthService(initialUser: user));

      final items = [
        ScanHistoryItem(
          id: 1,
          classification: '❌ Fake Job / Scam',
          confidenceScore: 90,
          scamIndicators: ['Fee demanded'],
          extractedText: 'Pay 1000 fee',
          createdAt: DateTime.now(),
        ),
        ScanHistoryItem(
          id: 2,
          classification: '✅ Genuine Job',
          confidenceScore: 10,
          scamIndicators: [],
          extractedText: 'Official job post',
          createdAt: DateTime.now(),
        ),
        ScanHistoryItem(
          id: 3,
          classification: '⚠️ Suspicious Job Post',
          confidenceScore: 40,
          scamIndicators: ['Unrealistic offer'],
          extractedText: 'Earn 10000 daily',
          createdAt: DateTime.now(),
        ),
      ];

      final historyProvider = HistoryProvider(
        historyService: MockHistoryService(items: items),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Statistics verified
      expect(find.text('Security Overview'), findsOneWidget);
      expect(find.text('Total Scans'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // 3 total scans
      expect(find.text('Scams Flagged'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // 1 scam, 1 suspicious, 1 genuine
      expect(find.text('Genuine'), findsOneWidget);

      // Recent scans section verified
      expect(find.text('Recent Scans'), findsOneWidget);
      expect(find.text('View All History'), findsOneWidget);
      expect(find.text('❌ Fake Job'), findsOneWidget);
      expect(find.text('✅ Genuine Job'), findsOneWidget);
    });

    testWidgets('ScanScreen provides navigation to TextScannerScreen and ImageScannerScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ScanProvider>(
          create: (_) => ScanProvider(scanService: MockScanService()),
          child: const MaterialApp(
            home: ScanScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Open Text Scanner'), findsOneWidget);
      expect(find.text('Open Image Scanner'), findsOneWidget);

      // Tap Open Text Scanner
      await tester.tap(find.text('Open Text Scanner'));
      await tester.pumpAndSettle();
      expect(find.byType(TextScannerScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen triggers logout confirmation', (WidgetTester tester) async {
      const user = User(id: 1, username: 'Elena Fisher', email: 'elena@example.com');
      final authProvider = AuthProvider(authService: MockAuthService(initialUser: user));

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Out'), findsOneWidget);

      // Scroll to ensure button is in viewport then tap
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to sign out of FraudGuard?'), findsOneWidget);
    });
  });
}
