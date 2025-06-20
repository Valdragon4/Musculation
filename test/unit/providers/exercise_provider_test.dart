import 'package:flutter_test/flutter_test.dart';
import 'package:musculation/models/exercise.dart';
import 'package:musculation/providers/exercise_provider.dart';
import '../../helpers/test_helpers.dart';
import '../../helpers/hive_helper.dart';

void main() {
  group('ExerciseProvider', () {
    setUp(() async {
      await initHive();
    });

    tearDown(() async {
      await cleanupHive();
    });

    test('état initial est une liste vide', () async {
      final container = createContainer();
      final exercises = container.read(exerciseNotifierProvider);
      expect(exercises, isEmpty);
    });

    test('ajout d\'un exercice', () async {
      final container = createContainer();
      final notifier = container.read(exerciseNotifierProvider.notifier);
      
      final exercise = Exercise(
        id: 'test_id',
        name: 'Squat',
        muscleGroup: 'Jambes',
        type: ExerciseType.force,
      );

      await notifier.addExercise(exercise);
      await container.pump();

      final exercises = container.read(exerciseNotifierProvider);
      expect(exercises, contains(exercise));
      expect(exercises.length, equals(1));
    });

    test('suppression d\'un exercice', () async {
      final container = createContainer();
      final notifier = container.read(exerciseNotifierProvider.notifier);
      
      final exercise = Exercise(
        id: 'test_id',
        name: 'Squat',
        muscleGroup: 'Jambes',
        type: ExerciseType.force,
      );

      await notifier.addExercise(exercise);
      await container.pump();

      await notifier.deleteExercise(exercise.id);
      await container.pump();

      final exercises = container.read(exerciseNotifierProvider);
      expect(exercises, isEmpty);
    });

    test('mise à jour d\'un exercice', () async {
      final container = createContainer();
      final notifier = container.read(exerciseNotifierProvider.notifier);
      
      final exercise = Exercise(
        id: 'test_id',
        name: 'Squat',
        muscleGroup: 'Jambes',
        type: ExerciseType.force,
      );

      await notifier.addExercise(exercise);
      await container.pump();

      final updatedExercise = Exercise(
        id: exercise.id,
        name: 'Front Squat',
        muscleGroup: 'Jambes',
        type: ExerciseType.force,
      );

      await notifier.updateExercise(updatedExercise);
      await container.pump();

      final exercises = container.read(exerciseNotifierProvider);
      expect(exercises.first.name, equals('Front Squat'));
    });
  });
} 
