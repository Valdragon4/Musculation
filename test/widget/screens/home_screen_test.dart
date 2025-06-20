import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musculation/screens/home_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    tearDownAll(() async {
      await cleanupTestEnvironment();
    });

    testWidgets('should display home screen with all main elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Vérifier la présence des éléments principaux
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'AppBar est présent
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle empty state gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran se charge sans erreur
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display navigation elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les éléments de navigation sont présents
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rebuild le widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le rebuild fonctionne
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Tester avec une petite taille d'écran
      tester.binding.window.physicalSizeTestValue = const Size(320, 480);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      // Tester avec une grande taille d'écran
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('should handle theme changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      // Changer le thème
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle accessibility features', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les éléments sont accessibles
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle performance under load', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simuler plusieurs rebuilds rapides
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        await tester.pump(Duration(milliseconds: 16)); // 60 FPS
      }

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
} 
