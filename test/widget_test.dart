// Weather App Widget Tests
// Comprehensive widget testing for the Weather Application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/main.dart';
import 'package:weatherapp/core/providers/auth_provider.dart';
import 'package:weatherapp/core/providers/weather_provider.dart';
import 'package:weatherapp/core/providers/theme_provider.dart';

void main() {
  group('Weather App Main Widget Tests', () {
    testWidgets('App initializes with proper providers', (WidgetTester tester) async {
      // Build the main app
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify that the app starts (splash screen should be visible)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App shows splash screen initially', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      
      // Should show splash screen content
      expect(find.text('Weather App'), findsOneWidget);
      expect(find.text('Stay ahead of the weather'), findsOneWidget);
    });

    testWidgets('Theme provider works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => WeatherProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: themeProvider.themeMode,
                home: const Scaffold(
                  body: Center(child: Text('Test App')),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('App handles provider states correctly', (WidgetTester tester) async {
      // Create test providers
      final authProvider = AuthProvider();
      final weatherProvider = WeatherProvider();
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: Consumer3<ThemeProvider, AuthProvider, WeatherProvider>(
            builder: (context, theme, auth, weather, child) {
              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      Text('Theme: ${theme.currentThemeName}'),
                      Text('Auth State: ${auth.state}'),
                      Text('Weather State: ${weather.state}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Verify provider states are accessible
      expect(find.textContaining('Theme:'), findsOneWidget);
      expect(find.textContaining('Auth State:'), findsOneWidget);
      expect(find.textContaining('Weather State:'), findsOneWidget);
    });
  });

  group('App Navigation Tests', () {
    testWidgets('App handles navigation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      
      // Wait for initial loading
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // App should show some content (splash, login, or home)
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });

  group('Performance Tests', () {
    testWidgets('App builds without performance issues', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // App should build reasonably quickly (less than 5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('App handles multiple rebuilds efficiently', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      
      // Trigger multiple rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }
      
      // Should still show the main app structure
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('App has proper semantic structure', (WidgetTester tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();
      
      // Check for semantic structure
      expect(tester.binding.pipelineOwner.semanticsOwner, isNotNull);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App handles provider errors gracefully', (WidgetTester tester) async {
      // This test ensures the app doesn't crash with provider errors
      await tester.pumpWidget(const WeatherApp());
      
      // Even if there are initialization errors, the app should still render
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
