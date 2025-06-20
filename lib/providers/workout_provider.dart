import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/workout.dart';
import '../services/database_service.dart';

part 'workout_provider.g.dart';

@riverpod
class WorkoutNotifier extends _$WorkoutNotifier {
  late final DatabaseService _db;

  @override
  List<Workout> build() {
    _db = DatabaseService();
    return _db.getAllWorkouts();
  }

  Future<void> addWorkout(Workout workout) async {
    await _db.addWorkout(workout);
    state = _db.getAllWorkouts();
  }

  Future<void> updateWorkout(Workout workout) async {
    await _db.updateWorkout(workout);
    state = _db.getAllWorkouts();
  }

  Future<void> deleteWorkout(String id) async {
    await _db.deleteWorkout(id);
    state = _db.getAllWorkouts();
  }
} 