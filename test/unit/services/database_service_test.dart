import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:musculation/services/database_service.dart';
import 'package:musculation/models/exercise.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/models/personal_record.dart';
import 'package:musculation/models/daily_tracking.dart';
import 'package:musculation/models/visual_progress.dart';

void main() {
  group('DatabaseService Tests', () {
    late DatabaseService databaseService;

    setUp(() {
      databaseService = DatabaseService();
    });

    group('Exercise Operations', () {
      test('should add exercise successfully', () async {
        final exercise = Exercise(
          id: '1',
          name: 'Squat',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Quadriceps, Glutes',
        );

        await databaseService.addExercise(exercise);
      });

      test('should get all exercises', () async {
        final exercises = [
          Exercise(id: '1', name: 'Squat', type: ExerciseType.hypertrophie, muscleGroup: 'Quadriceps, Glutes'),
          Exercise(id: '2', name: 'Bench Press', type: ExerciseType.hypertrophie, muscleGroup: 'Chest'),
        ];

        final result = databaseService.getAllExercises();

        expect(result, equals(exercises));
      });

      test('should get exercise by id', () async {
        final exercise = Exercise(
          id: '1',
          name: 'Squat',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Quadriceps, Glutes',
        );

        final result = await databaseService.getExerciseById('1');

        expect(result, equals(exercise));
      });

      test('should update exercise', () async {
        final exercise = Exercise(
          id: '1',
          name: 'Squat',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Quadriceps, Glutes',
        );

        await databaseService.updateExercise(exercise);
      });

      test('should delete exercise', () async {
        await databaseService.deleteExercise('1');
      });
    });

    group('Workout Operations', () {
      test('should add workout successfully', () async {
        final workout = Workout(
          id: '1',
          name: 'Push Day',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        await databaseService.addWorkout(workout);
      });

      test('should get all workouts sorted by date', () async {
        final workouts = [
          Workout(id: '1', name: 'Push Day', exercises: [], date: DateTime.now(), type: WorkoutType.fullBody),
          Workout(id: '2', name: 'Pull Day', exercises: [], date: DateTime.now(), type: WorkoutType.fullBody),
        ];

        await databaseService.addWorkout(workouts[0]);
        await databaseService.addWorkout(workouts[1]);

        final result = databaseService.getAllWorkouts();

        expect(result[0].id, equals('1'));
        expect(result[1].id, equals('2'));
      });

      test('should get workout by id', () async {
        final workout = Workout(
          id: '1',
          name: 'Push Day',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        final result = await databaseService.getWorkoutById('1');

        expect(result, equals(workout));
      });

      test('should update workout', () async {
        final workout = Workout(
          id: '1',
          name: 'Push Day',
          exercises: [],
          date: DateTime.now(),
          type: WorkoutType.fullBody,
        );

        await databaseService.updateWorkout(workout);
      });

      test('should delete workout', () async {
        await databaseService.deleteWorkout('1');
      });
    });

    group('Personal Record Operations', () {
      test('should add personal record successfully', () async {
        final pr = PersonalRecord(
          exerciseId: '1',
          sets: [
            WorkoutSet(repetitions: 5, weight: 100, rpe: 8, notes: 'Good form'),
          ],
          date: DateTime.now(),
        );

        await databaseService.addPersonalRecord(pr);
      });

      test('should get all personal records', () async {
        final prs = [
          PersonalRecord(exerciseId: '1', sets: [], date: DateTime.now(), notes: 'Good form'),
          PersonalRecord(exerciseId: '2', sets: [], date: DateTime.now(), notes: 'Feeling strong'),
        ];

        final result = await databaseService.getAllPersonalRecords();

        expect(result, equals(prs));
      });

      test('should get personal records by exercise id', () async {
        final prs = [
          PersonalRecord(exerciseId: '1', sets: [], date: DateTime.now(), notes: 'Good form'),
          PersonalRecord(exerciseId: '2', sets: [], date: DateTime.now(), notes: 'Feeling strong'),
        ];

        final result = await databaseService.getPersonalRecordsByExerciseId('1');

        expect(result, equals(prs));
      });
    });

    group('Migration Tests', () {
      test('should migrate personal records if needed', () async {
        final oldRecord = PersonalRecord(
          exerciseId: '1',
          sets: [], // Ancien format sans sets
          date: DateTime.now(),
          notes: 'Poids: 100 kg | Reps: 5',
        );

        await DatabaseService.migratePersonalRecordsIfNeeded();
      });

      test('should not migrate personal records if already in new format', () async {
        final newRecord = PersonalRecord(
          exerciseId: '1',
          sets: [
            WorkoutSet(repetitions: 5, weight: 100, rpe: 8, notes: 'Good form'),
          ],
          date: DateTime.now(),
          notes: 'Feeling strong',
        );

        await DatabaseService.migratePersonalRecordsIfNeeded();
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        expect(
          () => databaseService.getAllExercises(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty exercise list', () async {
        final result = databaseService.getAllExercises();

        expect(result, isEmpty);
      });

      test('should handle empty workout list', () async {
        final result = databaseService.getAllWorkouts();

        expect(result, isEmpty);
      });

      test('should return null when exercise not found', () async {
        final result = await databaseService.getExerciseById('999');

        expect(result, isNull);
      });

      test('should return null when workout not found', () async {  
        final result = await databaseService.getWorkoutById('999');

        expect(result, isNull);
      });
    });

    group('Box Access Tests', () {
      test('should access exercises box correctly', () {
        final box = DatabaseService.exercisesBox;
        expect(box, isNotNull);
      });

      test('should access workouts box correctly', () {
        final box = DatabaseService.workoutsBox;
        expect(box, isNotNull);
      });
    });
  });
} 
