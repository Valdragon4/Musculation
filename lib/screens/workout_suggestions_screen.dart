import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../providers/personal_record_provider.dart';
import '../services/workout_calculator_service.dart';
import '../theme/text_styles.dart';

class WorkoutSuggestionsScreen extends ConsumerStatefulWidget {
  const WorkoutSuggestionsScreen({super.key});

  @override
  ConsumerState<WorkoutSuggestionsScreen> createState() => _WorkoutSuggestionsScreenState();
}

class _WorkoutSuggestionsScreenState extends ConsumerState<WorkoutSuggestionsScreen> {
  TrainingObjective _selectedObjective = TrainingObjective.hypertrophie;
  UserLevel _selectedLevel = UserLevel.intermediaire;
  int? _targetRPE;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recordsAsync = ref.watch(personalRecordsProvider);
    final exercisesAsync = ref.watch(exerciseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suggestions d\'entraînement',
          style: AppTextStyles.title(context),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              // Navigation vers la page des records personnels
              context.go('/records');
            },
            tooltip: 'Voir les records personnels',
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun record disponible',
                    style: AppTextStyles.body(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des records personnels pour obtenir des suggestions',
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Paramètres de suggestion
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paramètres',
                      style: AppTextStyles.subtitle(context),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TrainingObjective>(
                            value: _selectedObjective,
                            decoration: InputDecoration(
                              labelText: 'Objectif',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: TrainingObjective.values.map((obj) => DropdownMenuItem(
                              value: obj,
                              child: Text(_getObjectiveName(obj)),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedObjective = value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<UserLevel>(
                            value: _selectedLevel,
                            decoration: InputDecoration(
                              labelText: 'Niveau',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: UserLevel.values.map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(_getLevelName(level)),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedLevel = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: _targetRPE,
                      decoration: InputDecoration(
                        labelText: 'RPE cible (optionnel)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Aucun')),
                        ...List.generate(5, (index) => DropdownMenuItem(
                          value: index + 6,
                          child: Text('RPE ${index + 6}'),
                        )),
                      ],
                      onChanged: (value) => setState(() => _targetRPE = value),
                    ),
                  ],
                ),
              ),
              
              // Liste des suggestions
              Expanded(
                child: Builder(
                  builder: (context) {
                    final exercises = exercisesAsync;
                    final suggestions = <ExerciseSuggestion>[];
                    
                    for (final exercise in exercises) {
                      final bestOneRM = WorkoutCalculatorService.findBestOneRM(records, exercise.id, exerciseName: exercise.name);
                      if (bestOneRM != null && bestOneRM > 0) {
                        suggestions.add(
                          WorkoutCalculatorService.generateExerciseSuggestion(
                            exercise: exercise,
                            oneRM: bestOneRM,
                            objective: _selectedObjective,
                            level: _selectedLevel,
                            targetRPE: _targetRPE,
                          ),
                        );
                      }
                    }
                    
                    if (suggestions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune suggestion disponible',
                              style: AppTextStyles.body(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajustez les paramètres ou ajoutez plus de records',
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        final exercise = exercises.firstWhere((ex) => ex.id == suggestion.exerciseId);
                        return _buildSuggestionCard(context, suggestion, exercise);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Erreur: $error',
            style: AppTextStyles.error(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, ExerciseSuggestion suggestion, Exercise exercise) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: AppTextStyles.cardTitle(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getObjectiveName(suggestion.objective),
                    style: AppTextStyles.caption(context).copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSuggestionRow(context, 'Charge', '${suggestion.suggestedWeight.toStringAsFixed(1)} kg'),
            _buildSuggestionRow(context, 'Répétitions', '${suggestion.suggestedReps} reps'),
            _buildSuggestionRow(context, 'Séries', '${suggestion.suggestedSets}'),
            _buildSuggestionRow(context, 'Repos', '${suggestion.suggestedRestTime} secondes'),
            _buildSuggestionRow(context, '% 1RM', '${suggestion.percentageOfOneRM.toStringAsFixed(1)}%'),
            if (_targetRPE != null)
              _buildSuggestionRow(context, 'RPE cible', 'RPE $_targetRPE'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption(context)),
          Text(value, style: AppTextStyles.body(context)),
        ],
      ),
    );
  }

  String _getObjectiveName(TrainingObjective objective) {
    switch (objective) {
      case TrainingObjective.force:
        return 'Force';
      case TrainingObjective.hypertrophie:
        return 'Hypertrophie';
      case TrainingObjective.endurance:
        return 'Endurance';
    }
  }

  String _getLevelName(UserLevel level) {
    switch (level) {
      case UserLevel.debutant:
        return 'Débutant';
      case UserLevel.intermediaire:
        return 'Intermédiaire';
      case UserLevel.avance:
        return 'Avancé';
    }
  }
} 