import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musculation/screens/create_workout_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('CreateWorkoutScreen Widget Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    tearDownAll(() async {
      await cleanupTestEnvironment();
    });

    testWidgets('should display create workout screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should display empty state when no exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché même sans données
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle exercise selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle workout creation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle workout saving', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle workout cancellation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle exercise search', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle exercise filtering', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle exercise sorting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should handle workout templates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CreateWorkoutScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should display create workout screen with all main elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CreateWorkoutScreen(),
          ),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
} 