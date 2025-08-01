import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/cardio_entry.dart';
import '../models/personal_record.dart';
import '../models/visual_progress.dart';
import '../models/daily_tracking.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static const String exercisesBoxName = 'exercises';
  static const String workoutsBoxName = 'workouts';
  static const String personalRecordsBoxName = 'personal_records';
  static const String visualProgressBoxName = 'visual_progress';
  static const String dailyTrackingBoxName = 'daily_tracking';

  static Future<void> migratePersonalRecordsIfNeeded() async {
    final box = Hive.box<PersonalRecord>(personalRecordsBoxName);
    final List<int> keysToUpdate = [];
    final List<PersonalRecord> newRecords = [];
    for (final key in box.keys) {
      final record = box.get(key);
      // Détection d'un ancien record (pas de sets, mais peut-être weight/reps dans notes)
      if (record != null && (record.sets.isEmpty)) {
        // Essayons d'extraire weight/reps depuis les notes (format: "Poids: X kg | Reps: Y")
        double? weight;
        int? reps;
        if (record.notes != null) {
          final poidsMatch = RegExp(r'([0-9]+([.,][0-9]+)?) ?kg').firstMatch(record.notes!);
          final repsMatch = RegExp(r'([0-9]+) ?reps?').firstMatch(record.notes!);
          if (poidsMatch != null) weight = double.tryParse(poidsMatch.group(1)!.replaceAll(',', '.'));
          if (repsMatch != null) reps = int.tryParse(repsMatch.group(1)!);
        }
        if (weight != null || reps != null) {
          newRecords.add(PersonalRecord(
            exerciseId: record.exerciseId,
            sets: [WorkoutSet(
              repetitions: reps ?? 0,
              weight: weight ?? 0,
              rpe: 0,
              notes: record.notes,
            )],
            date: record.date,
            notes: record.notes,
          ));
          keysToUpdate.add(key as int);
        }
      }
    }
    // Remplacer les anciens records par les nouveaux
    for (int i = 0; i < keysToUpdate.length; i++) {
      await box.put(keysToUpdate[i], newRecords[i]);
    }
  }

  static Future<void> migrateExercisesIfNeeded() async {
    final box = Hive.box<Exercise>(exercisesBoxName);
    final updatedKeys = <dynamic>[];

    for (final key in box.keys) {
      final exercise = box.get(key);

      // Si le type est une String, on tente de le convertir
      if (exercise != null && exercise.type is String) {
        try {
          final typeString = exercise.type as String;
          // On suppose que l'enum s'appelle ExerciseType et que toString() donne 'ExerciseType.nom'
          final ExerciseType newType = ExerciseType.values.firstWhere(
            (e) => e.toString().split('.').last == typeString,
            orElse: () => ExerciseType.autre, // Valeur par défaut si non trouvé
          );

          final newExercise = Exercise(
            id: exercise.id,
            name: exercise.name,
            muscleGroup: exercise.muscleGroup,
            type: newType,
          );

          await box.put(key, newExercise);
          updatedKeys.add(key);
        } catch (e) {
          print('Erreur de migration pour l\'exercice $key : $e');
        }
      }
    }
    if (updatedKeys.isNotEmpty) {
      print('Migration terminée pour les exercices : $updatedKeys');
    }
  }

  // Migration brute pour la box 'exercises' (avant ouverture typée)
  static Future<void> migrateExerciseBoxRaw() async {
    var box = await Hive.openBox('exercises');
    List<Map<String, dynamic>> rawExercises = [];

    for (var key in box.keys) {
      var raw = box.get(key);
      if (raw is Exercise) {
        rawExercises.add({
          'id': raw.id,
          'name': raw.name,
          'muscleGroup': raw.muscleGroup,
          'type': raw.type,
        });
      } else if (raw is Map) {
        final typeString = raw['type'];
        final ExerciseType newType = ExerciseType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
          orElse: () => ExerciseType.autre,
        );
        rawExercises.add({
          'id': raw['id'],
          'name': raw['name'],
          'muscleGroup': raw['muscleGroup'],
          'type': newType,
        });
      }
    }

    await box.clear();

    for (var ex in rawExercises) {
      final exercise = Exercise(
        id: ex['id'],
        name: ex['name'],
        muscleGroup: ex['muscleGroup'],
        type: ex['type'],
      );
      await box.add(exercise);
    }
    print('Migration brute terminée !');
  }

  static Future<void> migrateStringTypeToEnumIfNeeded() async {
    final box = Hive.box<Exercise>(exercisesBoxName);
    for (final key in box.keys) {
      final exercise = box.get(key);
      if (exercise != null && exercise.type is String) {
        final newType = exerciseTypeFromString(exercise.type as String);
        final newExercise = Exercise(
          id: exercise.id,
          name: exercise.name,
          muscleGroup: exercise.muscleGroup,
          type: newType,
        );
        await box.put(key, newExercise);
      }
    }
  }

  static Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    // Enregistrer les adaptateurs dans l'ordre
    Hive.registerAdapter(ExerciseTypeAdapter());
    Hive.registerAdapter(WorkoutTypeAdapter());
    Hive.registerAdapter(WorkoutSetAdapter());
    Hive.registerAdapter(WorkoutExerciseAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(CardioEntryAdapter());
    Hive.registerAdapter(IntervalSegmentAdapter());
    Hive.registerAdapter(PersonalRecordAdapter());
    Hive.registerAdapter(VisualProgressAdapter());
    Hive.registerAdapter(DailyTrackingAdapter());

    // Migration brute AVANT ouverture typée
    await migrateExerciseBoxRaw();
    await Hive.box('exercises').close();
    // Ouvrir les boîtes
    await Hive.openBox<Exercise>(exercisesBoxName);
    await migrateExercisesIfNeeded();
    await migrateStringTypeToEnumIfNeeded();
    await Hive.openBox<Workout>(workoutsBoxName);
    await Hive.openBox<PersonalRecord>(personalRecordsBoxName);
    await Hive.openBox<VisualProgress>(visualProgressBoxName);
    await Hive.openBox<DailyTracking>(dailyTrackingBoxName);
    // Appeler la migration après ouverture de la box
    await migratePersonalRecordsIfNeeded();
  }

  // Gestion des exercices
  static Box<Exercise> get exercisesBox => Hive.box<Exercise>(exercisesBoxName);
  
  Future<void> addExercise(Exercise exercise) async {
    await exercisesBox.put(exercise.id, exercise);
  }

  Future<void> updateExercise(Exercise exercise) async {
    await exercisesBox.put(exercise.id, exercise);
  }

  Future<void> deleteExercise(String id) async {
    await exercisesBox.delete(id);
  }

  List<Exercise> getAllExercises() {
    return exercisesBox.values.toList();
  }

  // Gestion des séances
  static Box<Workout> get workoutsBox => Hive.box<Workout>(workoutsBoxName);

  Future<void> addWorkout(Workout workout) async {
    await workoutsBox.put(workout.id, workout);
  }

  Future<void> updateWorkout(Workout workout) async {
    await workoutsBox.put(workout.id, workout);
  }

  Future<void> deleteWorkout(String id) async {
    await workoutsBox.delete(id);
  }

  List<Workout> getAllWorkouts() {
    return workoutsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<Workout?> getWorkoutById(String id) async {
    try {
      return getAllWorkouts().firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Exercise?> getExerciseById(String id) async {
    try {
      return getAllExercises().firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<PersonalRecord>> getPersonalRecordsByExerciseId(String exerciseId) async {
    return Hive.box<PersonalRecord>(personalRecordsBoxName)
        .values
        .where((pr) => pr.exerciseId == exerciseId)
        .toList();
  }

  Future<void> addPersonalRecord(PersonalRecord record) async {
    await Hive.box<PersonalRecord>(personalRecordsBoxName).add(record);
  }

  Future<List<PersonalRecord>> getAllPersonalRecords() async {
    return Hive.box<PersonalRecord>(personalRecordsBoxName).values.toList();
  }
} 