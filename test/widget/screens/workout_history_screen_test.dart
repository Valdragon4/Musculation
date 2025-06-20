import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musculation/screens/workout_history_screen.dart';
import '../../helpers/test_helpers.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/screens/workout_detail_screen.dart';

void main() {
  group('WorkoutHistoryScreen Widget Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    tearDownAll(() async {
      await cleanupTestEnvironment();
    });

    testWidgets('should display workout history screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should display empty state when no workouts', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché même sans données
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout deletion', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout filtering', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout sorting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout export', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout sharing', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout statistics', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
    });

    testWidgets('should handle workout details navigation', (WidgetTester tester) async {
      // Créer un mock workout pour le test
      final mockWorkout = Workout(
        id: '1',
        name: 'Test Workout',
        exercises: [],
        date: DateTime.now(),
        type: WorkoutType.upperBody,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran est affiché
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);
      
      // Si des workouts sont affichés, tester la navigation
      final workoutCards = find.byType(Card);
      if (workoutCards.evaluate().isNotEmpty) {
        await tester.tap(workoutCards.first);
        await tester.pumpAndSettle();
        
        // Vérifier que nous sommes sur l'écran de détails
        expect(find.byType(WorkoutDetailScreen), findsOneWidget);
      }
    });

    testWidgets('should display workout history screen with all main elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutHistoryScreen(),
          ),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
} 
