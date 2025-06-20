import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/workout_detail_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/exercises_screen.dart';
import '../screens/workout_history_screen.dart';
import '../screens/visual_progress_screen.dart';
import '../screens/personal_records_screen.dart';
import '../screens/create_workout_screen.dart';
import '../screens/workout_suggestions_screen.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/exercises',
            builder: (context, state) => const ExercisesScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const WorkoutHistoryScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const VisualProgressScreen(),
          ),
          GoRoute(
            path: '/records',
            builder: (context, state) => const PersonalRecordsScreen(),
          ),
          GoRoute(
            path: '/suggestions',
            builder: (context, state) => const WorkoutSuggestionsScreen(),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreateWorkoutScreen(),
          ),
          GoRoute(
            path: '/workout-detail',
            builder: (context, state) {
              final workoutId = state.extra as String;
              final workouts = ref.read(workoutNotifierProvider);
              Workout? workout;
              try {
                workout = workouts.firstWhere((w) => w.id == workoutId);
              } catch (e) {
                workout = null;
              }
              
              if (workout == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Séance non trouvée'),
                  ),
                );
              }
              return WorkoutDetailScreen(workout: workout);
            },
          ),
        ],
      ),
    ],
  );
}); 