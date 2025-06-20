import 'package:flutter_test/flutter_test.dart';
import 'package:musculation/models/exercise.dart';
import 'package:musculation/models/personal_record.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/services/workout_calculator_service.dart';

void main() {
  group('WorkoutCalculatorService', () {
    test('findBestOneRM retourne null si aucun record n\'est trouvé', () {
      final records = <PersonalRecord>[];
      final result = WorkoutCalculatorService.findBestOneRM(records, 'exercise_id');
      expect(result, isNull);
    });

    test('findBestOneRM calcule correctement le 1RM', () {
      final records = [
        PersonalRecord(
          exerciseId: 'exercise_id',
          sets: [
            WorkoutSet(
              weight: 100,
              repetitions: 5,
              rpe: 8,
              notes: null,
            ),
          ],
          date: DateTime.now(),
          notes: null,
        ),
        PersonalRecord(
          exerciseId: 'exercise_id',
          sets: [
            WorkoutSet(
              weight: 120,
              repetitions: 3,
              rpe: 8,
              notes: null,
            ),
          ],
          date: DateTime.now(),
          notes: null,
        ),
      ];

      final result = WorkoutCalculatorService.findBestOneRM(records, 'exercise_id');
      expect(result, isNotNull);
      // Le 1RM devrait être calculé avec la formule d'Epley
      // 1RM = weight * (1 + 0.0333 * reps)
      const expected1RM = 120 * (1 + 0.0333 * 3);
      expect(result, closeTo(expected1RM, 0.1));
    });

    test('generateExerciseSuggestion génère des suggestions cohérentes', () {
      final exercise = Exercise(
        id: 'exercise_id',
        name: 'Squat',
        muscleGroup: 'Jambes',
        type: ExerciseType.force,
      );

      final suggestion = WorkoutCalculatorService.generateExerciseSuggestion(
        exercise: exercise,
        oneRM: 100,
        objective: TrainingObjective.hypertrophie,
        level: UserLevel.intermediaire,
        targetRPE: 8,
      );

      expect(suggestion.exerciseId, equals(exercise.id));
      expect(suggestion.suggestedWeight, isPositive);
      expect(suggestion.suggestedReps, isPositive);
      expect(suggestion.suggestedSets, isPositive);
      expect(suggestion.suggestedRestTime, isPositive);
      expect(suggestion.percentageOfOneRM, inInclusiveRange(0, 100));
    });
  });
} 
