import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

part 'exercise_provider.g.dart';

@riverpod
class ExerciseNotifier extends _$ExerciseNotifier {
  late final DatabaseService _db;

  @override
  List<Exercise> build() {
    _db = DatabaseService();
    return _db.getAllExercises();
  }

  Future<void> addExercise(Exercise exercise) async {
    await _db.addExercise(exercise);
    state = _db.getAllExercises();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _db.updateExercise(exercise);
    state = _db.getAllExercises();
  }

  Future<void> deleteExercise(String id) async {
    await _db.deleteExercise(id);
    state = _db.getAllExercises();
  }

  void addExercises(List<Exercise> exercises) {
    for (final exercise in exercises) {
      addExercise(exercise);
    }
  }
} 