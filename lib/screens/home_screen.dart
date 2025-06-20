import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import 'package:go_router/go_router.dart';
import '../models/workout.dart';
import '../theme/text_styles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suivi Musculation',
          style: AppTextStyles.title(context),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 2,
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create');
        },
        icon: const Icon(Icons.add),
        label: Text(
          'Nouvelle séance',
          style: AppTextStyles.button(context),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF181818),
                    const Color(0xFF232323),
                  ]
                : [
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.surface,
                  ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              _buildQuickLinks(context, colorScheme),
              const SizedBox(height: 24),
              if (workouts.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 80,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bienvenue dans Suivi Musculation',
                        style: AppTextStyles.subtitle(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Commencez à progresser en enregistrant votre première séance !',
                        style: AppTextStyles.body(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                _buildRecentWorkouts(context, workouts, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickLink(
            context,
            'Progression',
            Icons.photo_camera,
            () => context.push('/progress'),
            colorScheme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickLink(
            context,
            'PR',
            Icons.emoji_events,
            () => context.push('/records'),
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.cardTitle(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context, List<Workout> workouts, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Séances récentes',
          style: AppTextStyles.subtitle(context),
        ),
        const SizedBox(height: 16),
        ...workouts.take(5).map((workout) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(20),
                color: isDark ? colorScheme.surface : colorScheme.surface,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/workout-detail', extra: workout.id),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(workout.date),
                                style: AppTextStyles.cardTitle(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                workout.name,
                                style: AppTextStyles.subtitle(context),
                              ),
                              const SizedBox(height: 8),
                              ...workout.exercises.map((exercise) => Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_right_alt,
                                          size: 18,
                                          color: colorScheme.primary.withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${exercise.exercise.name} (${exercise.sets.length} séries)',
                                            style: AppTextStyles.body(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 12, top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${workout.exercises.length} exercice${workout.exercises.length > 1 ? 's' : ''}',
                            style: AppTextStyles.bodyBold(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
} 