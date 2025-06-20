import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../theme/text_styles.dart';
import 'home_screen.dart';
import 'workout_detail_screen.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique',
          style: AppTextStyles.title(context),
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final history = ref.watch(workoutNotifierProvider);

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aucun entraînement terminé',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _startWorkout(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Enregistrer une séance'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final Map<DateTime, List<Workout>> workoutsByWeek = {};
          for (final workout in history) {
            final weekStart = _getWeekStart(workout.date);
            workoutsByWeek.putIfAbsent(weekStart, () => []).add(workout);
          }
          final sortedWeeks = workoutsByWeek.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          DateTime selectedWeek = sortedWeeks.first;
          String searchQuery = '';

          return StatefulBuilder(
            builder: (context, setState) {
              final searchBar = Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une séance ou un exercice',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  style: AppTextStyles.input(context),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              );

              final filteredWorkouts = workoutsByWeek[selectedWeek]!
                  .where((workout) {
                    final nameMatch = workout.name.toLowerCase().contains(searchQuery);
                    final exerciseMatch = workout.exercises.any((ex) => ex.exercise.name.toLowerCase().contains(searchQuery));
                    return searchQuery.isEmpty || nameMatch || exerciseMatch;
                  })
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchBar,
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<DateTime>(
                      value: selectedWeek,
                      isExpanded: true,
                      items: [
                        for (final weekStart in sortedWeeks)
                          DropdownMenuItem(
                            value: weekStart,
                            child: Text(
                              'Semaine du ${_formatDate(weekStart)} au ${_formatDate(weekStart.add(const Duration(days: 6)))}',
                              style: AppTextStyles.subtitle(context),
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedWeek = value;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...filteredWorkouts.map((workout) => Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.white, width: 1),
                          ),
                          child: ListTile(
                            title: Text(workout.name),
                            subtitle: Text(
                              'Terminé le ${_formatDate(workout.date)}\n${_getWorkoutTypeName(workout.type)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailScreen(workout: workout),
                                ),
                              );
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getWorkoutTypeName(WorkoutType type) {
    switch (type) {
      case WorkoutType.upperBody:
        return 'Haut du corps';
      case WorkoutType.lowerBody:
        return 'Jambes';
      case WorkoutType.fullBody:
        return 'Full body';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.other:
        return 'Autre';
    }
  }
} 