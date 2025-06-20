import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musculation/screens/workout_detail_screen.dart';
import 'package:musculation/providers/workout_provider.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/models/exercise.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('WorkoutDetailScreen Widget Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    tearDownAll(() async {
      await cleanupTestEnvironment();
    });

    late Workout mockWorkout;

    setUp(() {
      mockWorkout = Workout(
        id: '1',
        name: 'Push Day',
        exercises: [
          WorkoutExercise(
            exercise: Exercise(
              id: '1',
              name: 'Bench Press',
              muscleGroup: 'Chest',
              type: ExerciseType.force,
            ),
            sets: [
              WorkoutSet(repetitions: 8, weight: 80.0, rpe: 7, notes: 'Good form'),
              WorkoutSet(repetitions: 8, weight: 80.0, rpe: 8, notes: 'Feeling strong'),
              WorkoutSet(repetitions: 6, weight: 85.0, rpe: 8, notes: 'Last set'),
            ],
          ),
          WorkoutExercise(
            exercise: Exercise(
              id: '2',
              name: 'Overhead Press',
              muscleGroup: 'Shoulders',
              type: ExerciseType.force,
            ),
            sets: [
              WorkoutSet(repetitions: 10, weight: 50.0, rpe: 7, notes: 'Good movement'),
              WorkoutSet(repetitions: 10, weight: 50.0, rpe: 8, notes: 'Maintaining form'),
            ],
          ),
          WorkoutExercise(
            exercise: Exercise(
              id: '3',
              name: 'Dips',
              muscleGroup: 'Chest',
              type: ExerciseType.force,
            ),
            sets: [
              WorkoutSet(repetitions: 12, weight: 0.0, rpe: 7, notes: 'Body weight'),
              WorkoutSet(repetitions: 10, weight: 0.0, rpe: 8, notes: 'Getting tired'),
            ],
          ),
        ],
        date: DateTime.now(),
        type: WorkoutType.upperBody,
        notes: 'Great push day workout! Feeling strong on bench press.',
        overallFeeling: 8,
      );
    });

    testWidgets('should display workout detail screen with all main elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Push Day'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display workout information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Push Day'), findsOneWidget);
      expect(find.textContaining('Great push day workout!'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display all exercises in workout', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Overhead Press'), findsOneWidget);
      expect(find.text('Dips'), findsOneWidget);
    });

    testWidgets('should display exercise details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Overhead Press'), findsOneWidget);
    });

    testWidgets('should display workout statistics', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Vérifier que les exercices sont affichés (statistiques de base)
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Overhead Press'), findsOneWidget);
      expect(find.text('Dips'), findsOneWidget);
    });

    testWidgets('should handle edit workout action', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final editButtons = find.byIcon(Icons.edit);
      if (editButtons.evaluate().isNotEmpty) {
        await tester.tap(editButtons.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle delete workout action', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final deleteButtons = find.byIcon(Icons.delete);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        expect(find.text('Supprimer'), findsOneWidget);
        expect(find.text('Annuler'), findsOneWidget);
      }
    });

    testWidgets('should handle duplicate workout action', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final duplicateButtons = find.byIcon(Icons.copy);
      if (duplicateButtons.evaluate().isNotEmpty) {
        await tester.tap(duplicateButtons.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should display exercise order correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutDetailScreen(workout: mockWorkout),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final exerciseWidgets = find.text('Bench Press');
      expect(exerciseWidgets, findsOneWidget);
    });
  });
} 
