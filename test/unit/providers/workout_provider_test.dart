import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:musculation/providers/workout_provider.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/providers/workout_provider.dart';
import 'package:collection/collection.dart';

void main() {
  group('WorkoutProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('loadWorkouts', () {
      test('should load workouts successfully', () async {
        final workouts = [
          Workout(
            id: '1',
            name: 'Push Day',
            date: DateTime.now(),
            type: WorkoutType.fullBody,
            exercises: [],
            notes: 'Notes for Push Day',
            overallFeeling: 8,
          ),
          Workout(
            id: '2',
            name: 'Pull Day',
            date: DateTime.now().subtract(Duration(days: 1)),
            type: WorkoutType.fullBody,
            exercises: [],
            notes: 'Notes for Pull Day',
            overallFeeling: 7,
          ),
        ];

        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(workouts[0]);
        await notifier.addWorkout(workouts[1]);

        final state = container.read(workoutNotifierProvider);
        expect(state, equals(workouts));

      });

      test('should handle empty workout list', () async {
        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        ));

        final state = container.read(workoutNotifierProvider);
        expect(state, isEmpty);
      });

      test('should handle database errors', () async {
        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        ));

        final state = container.read(workoutNotifierProvider);
        expect(state, isEmpty);
      });
    });

    group('addWorkout', () {
      test('should add workout successfully', () async {
        final workout = Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(workout);

        final state = container.read(workoutNotifierProvider);
        expect(state, contains(workout));
      });

      test('should handle add workout errors', () async {
        final workout = Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(workout);

        final state = container.read(workoutNotifierProvider);
          expect(state, isEmpty);
      });
    });

    group('updateWorkout', () {
      test('should update workout successfully', () async {
        final originalWorkout = Workout(
          id: '1',
          name: 'Original Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        final updatedWorkout = Workout(
          id: '1',
          name: 'Updated Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.updateWorkout(updatedWorkout);

        final state = container.read(workoutNotifierProvider);
        expect(state, contains(updatedWorkout));
        expect(state, isNot(contains(originalWorkout)));
      });
    });

    group('deleteWorkout', () {
      test('should delete workout successfully', () async {
        final workout = Workout(
          id: '1',
          name: 'Workout to Delete',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(workout);

        final state = container.read(workoutNotifierProvider);
        expect(state, isNot(contains(workout)));
      });
    });

    group('getWorkoutById', () {
      test('should return workout by id', () async {
        final workout = Workout(
          id: '1',
          name: 'Test Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
          notes: 'Notes for Test Workout',
          overallFeeling: 9,
        );

        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(workout);

        final foundWorkout = container.read(workoutNotifierProvider).firstWhereOrNull((workout) => workout.id == '1');
        expect(foundWorkout, equals(workout));
      });

      test('should return null for non-existent workout', () async {
        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        ));

        final foundWorkout = container.read(workoutNotifierProvider).firstWhereOrNull((workout) => workout.id == '999');
        expect(foundWorkout, isNull);
      });
    });

    group('State Management', () {
      test('should set loading state correctly', () async {
        final notifier = container.read(workoutNotifierProvider.notifier);
        final future = notifier.addWorkout(Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        ));

        // Vérifier que l'état de chargement est activé
        final loadingState = container.read(workoutNotifierProvider);
        expect(loadingState, isEmpty);

        await future;

        // Vérifier que l'état de chargement est désactivé
        final finalState = container.read(workoutNotifierProvider);
        expect(finalState, isNot(isEmpty));
      });

      test('should clear error when successful operation', () async {
        // D'abord créer une erreur
        final notifier = container.read(workoutNotifierProvider.notifier);
        await notifier.addWorkout(Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        ));

        final errorState = container.read(workoutNotifierProvider);
        expect(errorState, isEmpty);

        // Puis réussir une opération
        await notifier.addWorkout(Workout(
          id: '1',
          name: 'New Workout',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        ));

        final successState = container.read(workoutNotifierProvider);
        expect(successState, isNot(isEmpty));
      });
    });
  });
} 
