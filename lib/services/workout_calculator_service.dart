import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/personal_record.dart';

enum TrainingObjective { force, hypertrophie, endurance }
enum UserLevel { debutant, intermediaire, avance }

class WorkoutCalculatorService {
  /// Calcule le 1RM estimé à partir d'une charge et d'un nombre de répétitions
  /// Utilise la formule d'Epley : 1RM = charge * (1 + 0.0333 * reps)
  static double calculateOneRM(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    
    return weight * (1 + 0.0333 * reps);
  }

  /// Calcule le 1RM pour les exercices Hyrox spécifiques
  static double calculateHyroxOneRM(String exerciseName, double weight, int reps, {double? distance, int? time}) {
    switch (exerciseName.toLowerCase()) {
      case 'farmer carry':
      case 'farmer\'s carry':
      case 'farmer walk':
        return _calculateFarmerCarryOneRM(weight, distance ?? 50);
      
      case 'thruster':
        return _calculateThrusterOneRM(weight, reps);
      
      case 'wall ball':
      case 'wallball':
        return _calculateWallBallOneRM(weight, reps);
      
      case 'burpee box jump over':
      case 'burpee box jump':
        return _calculateBurpeeBoxJumpOneRM(time ?? 120); // 2 minutes par défaut
      
      case 'row':
      case 'rowing':
        return _calculateRowingOneRM(time ?? 90); // 1:30 par défaut
      
      case 'deadlift':
      case 'clean':
      case 'snatch':
        // Pour les mouvements olympiques, utiliser la formule standard
        return calculateOneRM(weight, reps);
      
      default:
        // Pour les autres exercices, utiliser la formule standard
        return calculateOneRM(weight, reps);
    }
  }

  /// Calcule le 1RM pour Farmer Carry basé sur la distance
  static double _calculateFarmerCarryOneRM(double weight, double distance) {
    double multiplier;
    if (distance < 25) {
      multiplier = 1.5; // Distance courte
    } else if (distance <= 50) {
      multiplier = 1.3; // Distance moyenne
    } else {
      multiplier = 1.2; // Distance longue
    }
    return weight * multiplier;
  }

  /// Calcule le 1RM pour Thrusters basé sur le Clean ou Front Squat
  static double _calculateThrusterOneRM(double weight, int reps) {
    // Si c'est déjà un 1RM (reps = 1), appliquer le facteur de conversion
    if (reps == 1) {
      return weight * 1.4; // 1RM Thruster ≈ 0.7 × 1RM Clean, donc inverse
    }
    
    // Sinon, calculer d'abord le 1RM puis appliquer le facteur
    double estimatedClean = calculateOneRM(weight, reps);
    return estimatedClean * 0.7; // 1RM Thruster ≈ 0.7 × 1RM Clean
  }

  /// Calcule le 1RM pour Wall Balls
  static double _calculateWallBallOneRM(double weight, int reps) {
    if (reps == 1) {
      return weight * 2.0; // 1RM Wall Ball ≈ 0.5 × 1RM Front Squat, donc inverse
    }
    
    double estimatedFrontSquat = calculateOneRM(weight, reps);
    return estimatedFrontSquat * 0.5; // 1RM Wall Ball ≈ 0.5 × 1RM Front Squat
  }

  /// Calcule le niveau pour Burpee Box Jump (pas de 1RM classique)
  static double _calculateBurpeeBoxJumpOneRM(int timeSeconds) {
    // Plus le temps est court, plus le niveau est élevé
    // 60 secondes = niveau 100, 180 secondes = niveau 50
    if (timeSeconds <= 60) return 100;
    if (timeSeconds >= 180) return 50;
    
    return 100 - ((timeSeconds - 60) * 50 / 120);
  }

  /// Calcule le niveau pour Rowing (pas de 1RM classique)
  static double _calculateRowingOneRM(int timeSeconds) {
    // Plus le temps est court, plus le niveau est élevé
    // 60 secondes = niveau 100, 120 secondes = niveau 80
    if (timeSeconds <= 60) return 100;
    if (timeSeconds >= 120) return 80;
    
    return 100 - ((timeSeconds - 60) * 20 / 60);
  }

  /// Calcule la charge à utiliser pour un pourcentage donné du 1RM
  static double calculateWeightFromPercentage(double oneRM, double percentage) {
    return (oneRM * percentage / 100).roundToDouble();
  }

  /// Définit les zones d'entraînement selon l'objectif
  static TrainingZone getTrainingZone(TrainingObjective objective) {
    switch (objective) {
      case TrainingObjective.force:
        return TrainingZone(
          percentageRange: Range(85, 100),
          repsRange: Range(1, 5),
          setsRange: Range(3, 6),
          restTimeRange: Range(180, 300), // 3-5 minutes
        );
      case TrainingObjective.hypertrophie:
        return TrainingZone(
          percentageRange: Range(65, 80),
          repsRange: Range(6, 12),
          setsRange: Range(3, 5),
          restTimeRange: Range(60, 120), // 1-2 minutes
        );
      case TrainingObjective.endurance:
        return TrainingZone(
          percentageRange: Range(50, 65),
          repsRange: Range(12, 20),
          setsRange: Range(2, 4),
          restTimeRange: Range(30, 60), // 30-60 secondes
        );
    }
  }

  /// Ajuste les paramètres selon le niveau de l'utilisateur
  static TrainingZone adjustForUserLevel(TrainingZone zone, UserLevel level) {
    switch (level) {
      case UserLevel.debutant:
        return TrainingZone(
          percentageRange: Range(
            zone.percentageRange.min * 0.9,
            zone.percentageRange.max * 0.9,
          ),
          repsRange: Range(
            zone.repsRange.min.toDouble(),
            (zone.repsRange.max * 0.8).toDouble(),
          ),
          setsRange: Range(
            zone.setsRange.min.toDouble(),
            (zone.setsRange.max * 0.8).toDouble(),
          ),
          restTimeRange: Range(
            zone.restTimeRange.min * 1.2,
            zone.restTimeRange.max * 1.2,
          ),
        );
      case UserLevel.intermediaire:
        return zone; // Pas d'ajustement
      case UserLevel.avance:
        return TrainingZone(
          percentageRange: Range(
            zone.percentageRange.min * 1.05,
            zone.percentageRange.max * 1.05,
          ),
          repsRange: zone.repsRange,
          setsRange: Range(
            zone.setsRange.min.toDouble(),
            (zone.setsRange.max + 1).toDouble(),
          ),
          restTimeRange: Range(
            zone.restTimeRange.min * 0.9,
            zone.restTimeRange.max * 0.9,
          ),
        );
    }
  }

  /// Ajuste la charge selon le RPE cible (Rate of Perceived Exertion)
  /// RPE 8 = garder 2 reps en réserve, RPE 9 = garder 1 rep en réserve
  static double adjustWeightForRPE(double baseWeight, int targetRPE, int targetReps) {
    if (targetRPE < 6 || targetRPE > 10) return baseWeight;
    
    // Ajustement basé sur le RPE
    double adjustmentFactor = 1.0;
    switch (targetRPE) {
      case 6: // Très facile
        adjustmentFactor = 0.85;
        break;
      case 7: // Facile
        adjustmentFactor = 0.90;
        break;
      case 8: // Modéré (2 reps en réserve)
        adjustmentFactor = 0.95;
        break;
      case 9: // Difficile (1 rep en réserve)
        adjustmentFactor = 1.0;
        break;
      case 10: // Maximum
        adjustmentFactor = 1.05;
        break;
    }
    
    return (baseWeight * adjustmentFactor).roundToDouble();
  }

  /// Génère une proposition de séance complète
  static WorkoutSession generateWorkoutSession({
    required TrainingObjective objective,
    required Map<String, double> exerciseOneRMs, // exerciseId -> 1RM
    required List<Exercise> exercises,
    required UserLevel level,
    int? targetRPE,
  }) {
    final zone = adjustForUserLevel(getTrainingZone(objective), level);
    final List<CalculatedWorkoutExercise> workoutExercises = [];

    for (final exercise in exercises) {
      final oneRM = exerciseOneRMs[exercise.id];
      if (oneRM == null || oneRM <= 0) continue;

      final percentage = _getRandomPercentageInRange(zone.percentageRange);
      double weight = calculateWeightFromPercentage(oneRM, percentage);
      
      if (targetRPE != null) {
        final reps = _getRandomInRange(zone.repsRange);
        weight = adjustWeightForRPE(weight, targetRPE, reps);
      }

      final reps = _getRandomInRange(zone.repsRange);
      final sets = _getRandomInRange(zone.setsRange);
      final restTime = _getRandomInRange(zone.restTimeRange);

      final workoutSets = List.generate(sets, (index) => WorkoutSet(
        repetitions: reps,
        weight: weight,
        rpe: 0,
        notes: null,
      ));

      workoutExercises.add(CalculatedWorkoutExercise(
        exerciseId: exercise.id,
        sets: workoutSets,
        restTimeSeconds: restTime,
      ));
    }

    return WorkoutSession(
      exercises: workoutExercises,
      objective: objective,
      level: level,
      estimatedDuration: _calculateEstimatedDuration(workoutExercises),
    );
  }

  /// Génère des suggestions pour un exercice spécifique
  static ExerciseSuggestion generateExerciseSuggestion({
    required Exercise exercise,
    required double oneRM,
    required TrainingObjective objective,
    required UserLevel level,
    int? targetRPE,
  }) {
    final zone = adjustForUserLevel(getTrainingZone(objective), level);
    
    final percentage = _getRandomPercentageInRange(zone.percentageRange);
    double weight = calculateWeightFromPercentage(oneRM, percentage);
    
    final reps = _getRandomInRange(zone.repsRange);
    final sets = _getRandomInRange(zone.setsRange);
    final restTime = _getRandomInRange(zone.restTimeRange);

    if (targetRPE != null) {
      weight = adjustWeightForRPE(weight, targetRPE, reps);
    }

    return ExerciseSuggestion(
      exerciseId: exercise.id,
      suggestedWeight: weight,
      suggestedReps: reps,
      suggestedSets: sets,
      suggestedRestTime: restTime,
      percentageOfOneRM: percentage,
      objective: objective,
    );
  }

  /// Trouve le meilleur 1RM pour un exercice à partir des records personnels
  static double? findBestOneRM(List<PersonalRecord> records, String exerciseId, {String? exerciseName}) {
    double? bestOneRM;
    
    for (final record in records) {
      if (record.exerciseId != exerciseId) continue;
      
      for (final set in record.sets) {
        if (set.weight > 0 && set.repetitions > 0) {
          double oneRM;
          
          // Utiliser les formules Hyrox spécifiques si applicable
          if (exerciseName != null && _isHyroxExercise(exerciseName)) {
            oneRM = calculateHyroxOneRM(exerciseName, set.weight, set.repetitions);
          } else {
            oneRM = calculateOneRM(set.weight, set.repetitions);
          }
          
          if (bestOneRM == null || oneRM > bestOneRM) {
            bestOneRM = oneRM;
          }
        }
      }
    }
    
    return bestOneRM;
  }

  /// Vérifie si un exercice est un exercice Hyrox
  static bool _isHyroxExercise(String exerciseName) {
    final hyroxExercises = [
      'farmer carry', 'farmer\'s carry', 'farmer walk',
      'thruster', 'wall ball', 'wallball',
      'burpee box jump over', 'burpee box jump',
      'row', 'rowing', 'deadlift', 'clean', 'snatch'
    ];
    
    return hyroxExercises.contains(exerciseName.toLowerCase());
  }

  // Méthodes utilitaires privées
  static double _getRandomPercentageInRange(Range range) {
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100.0;
    return range.min + (range.max - range.min) * random;
  }

  static int _getRandomInRange(Range range) {
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 100.0;
    return (range.min + (range.max - range.min) * random).round();
  }

  static int _calculateEstimatedDuration(List<CalculatedWorkoutExercise> exercises) {
    int totalTime = 0;
    for (final exercise in exercises) {
      // Temps estimé par série (45 secondes) + temps de repos
      final timePerSet = 45;
      final totalRestTime = exercise.restTimeSeconds * (exercise.sets.length - 1);
      totalTime += (timePerSet * exercise.sets.length) + totalRestTime;
    }
    return totalTime;
  }
}

/// Classe pour représenter une plage de valeurs
class Range {
  final double min;
  final double max;

  Range(this.min, this.max);
}

/// Classe pour représenter une zone d'entraînement
class TrainingZone {
  final Range percentageRange;
  final Range repsRange;
  final Range setsRange;
  final Range restTimeRange;

  TrainingZone({
    required this.percentageRange,
    required this.repsRange,
    required this.setsRange,
    required this.restTimeRange,
  });
}

/// Classe pour représenter une suggestion d'exercice
class ExerciseSuggestion {
  final String exerciseId;
  final double suggestedWeight;
  final int suggestedReps;
  final int suggestedSets;
  final int suggestedRestTime;
  final double percentageOfOneRM;
  final TrainingObjective objective;

  ExerciseSuggestion({
    required this.exerciseId,
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.suggestedSets,
    required this.suggestedRestTime,
    required this.percentageOfOneRM,
    required this.objective,
  });
}

/// Classe pour représenter une séance d'entraînement complète
class WorkoutSession {
  final List<CalculatedWorkoutExercise> exercises;
  final TrainingObjective objective;
  final UserLevel level;
  final int estimatedDuration; // en secondes

  WorkoutSession({
    required this.exercises,
    required this.objective,
    required this.level,
    required this.estimatedDuration,
  });
}

/// Classe pour représenter un exercice dans une séance
class CalculatedWorkoutExercise {
  final String exerciseId;
  final List<WorkoutSet> sets;
  final int restTimeSeconds;

  CalculatedWorkoutExercise({
    required this.exerciseId,
    required this.sets,
    required this.restTimeSeconds,
  });
} 