import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';

final workoutHistoryProvider = StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<List<Workout>>>((ref) {
  return WorkoutHistoryNotifier();
});

class WorkoutHistoryNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  WorkoutHistoryNotifier() : super(const AsyncValue.data([]));

  void addWorkout(Workout workout) {
    state.whenData((workouts) {
      state = AsyncValue.data([...workouts, workout]);
    });
  }

  void deleteWorkout(String id) {
    state.whenData((workouts) {
      state = AsyncValue.data(workouts.where((workout) => workout.id != id).toList());
    });
  }
} 