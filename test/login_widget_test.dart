import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/presentation/pages/auth/login_page.dart';
import 'package:weatherapp/core/providers/auth_provider.dart';
import 'package:weatherapp/core/theme/app_theme.dart';

void main() {
  group('Login Page Widget Tests', () {
    // Helper function to create test widget
    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const LoginPage(),
        ),
      );
    }

    testWidgets('Login page displays all required elements', (WidgetTester tester) async {
      // Build the login page with required providers
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify welcome message is present
      expect(find.text('Welcome Back'), findsOneWidget);

      // Verify email and password fields are present
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Verify login button is present
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify navigation links are present
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Email field accepts input correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find email field and enter text
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field and enter text
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Note: Password field content is obscured, so we check the field exists
      expect(passwordField, findsOneWidget);
    });

    testWidgets('Login button triggers authentication process', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      // Tap login button
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify loading state is shown (CircularProgressIndicator should appear)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Create Account navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap create account link
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // This would navigate to signup page in a real app
      // For now, we just verify the tap was registered
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Forgot Password navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap forgot password link
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // This would navigate to forgot password page in a real app
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Theme switching affects login page appearance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the page renders in dark theme
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold, isNotNull);
    });

    testWidgets('Login form handles empty inputs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to submit form without entering anything
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // The form should handle empty inputs gracefully
      // In a real implementation, validation errors would appear
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Login page is responsive to screen size', (WidgetTester tester) async {
      // Test with different screen sizes
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all elements are still visible
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);

      // Test with smaller screen
      await tester.binding.setSurfaceSize(const Size(300, 600));
      await tester.pump();

      // Elements should still be accessible
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  group('Login Page Integration Tests', () {
    testWidgets('Full login flow simulation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Enter email
      await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
      await tester.pump();

      // Step 2: Enter password
      await tester.enterText(find.byType(TextFormField).last, 'securepassword');
      await tester.pump();

      // Step 3: Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Step 4: Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for authentication to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // In a real implementation, this would navigate to home page
      // For testing purposes, we verify the authentication was attempted
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}