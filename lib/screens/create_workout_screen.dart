import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/cardio_entry.dart';
import '../providers/workout_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/personal_record_provider.dart';
import '../theme/text_styles.dart';
import '../services/workout_calculator_service.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateWorkoutScreen extends ConsumerStatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  ConsumerState<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  WorkoutType _selectedType = WorkoutType.upperBody;
  final List<WorkoutExercise> _exercises = [];
  CardioEntry? _cardioEntry;
  int? _overallFeeling;
  bool _hasUnsavedChanges = false;
  final _hyroxWeightTextController = TextEditingController();

  String _setDescription(WorkoutSet set, String type) {
    List<String> parts = [];
    if (set.notes != null && set.notes!.startsWith('pause:')) {
      parts.add(set.notes!);
      return parts.join(' | ');
    }
    if (type == ExerciseType.hyrox.toString()) {
      if (set.rpe != 0) parts.add('Distance: ${set.rpe} m');
      if (set.repetitions != 0) parts.add('Répétitions: ${set.repetitions}');
      if (set.notes != null && set.notes!.isNotEmpty) {
        for (final notePart in set.notes!.split('|')) {
          final trimmed = notePart.trim();
          if (trimmed.isNotEmpty) parts.add(trimmed);
        }
      }
    } else {
      if (set.repetitions != 0) parts.add('${set.repetitions} reps');
      if (set.weight != 0) parts.add('${set.weight} kg');
      if (set.rpe != 0) parts.add('RPE: ${set.rpe}');
      if (set.notes != null && set.notes!.isNotEmpty) parts.add(set.notes!);
    }
    return parts.join(' | ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _hyroxWeightTextController.dispose();
    super.dispose();
  }

  void _markAsModified() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Modifications non enregistrées',
          style: AppTextStyles.title(context),
        ),
        content: Text(
          'Voulez-vous vraiment quitter sans enregistrer les modifications ?',
          style: AppTextStyles.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: AppTextStyles.button(context),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Quitter',
              style: AppTextStyles.button(context),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (didPop) return;
        _onWillPop().then((shouldPop) {
          if (shouldPop && context.mounted) {
            context.pop();
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Nouvelle séance',
            style: AppTextStyles.title(context),
          ),
          backgroundColor: colorScheme.primary,
          elevation: 2,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _saveWorkout,
              tooltip: 'Enregistrer',
            ),
          ],
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
                      colorScheme.primary.withAlpha(20),
                      colorScheme.surface,
                    ],
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de la séance',
                    labelStyle: AppTextStyles.label(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                  style: AppTextStyles.input(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom de séance';
                    }
                    return null;
                  },
                  onChanged: (_) => _markAsModified(),
                ),
                const SizedBox(height: 20),
                _buildTypeSection(context),
                const SizedBox(height: 20),
                _buildExercisesSection(context),
                const SizedBox(height: 20),
                _buildNotesSection(context),
                const SizedBox(height: 20),
                _buildFeelingSection(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de séance',
              style: AppTextStyles.subtitle(context),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WorkoutType>(
              value: _selectedType,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              dropdownColor: colorScheme.surface,
              style: AppTextStyles.input(context),
              items: WorkoutType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    _getWorkoutTypeName(type),
                    style: AppTextStyles.input(context),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                  _markAsModified();
                }
              },
            ),
          ],
        ),
      ),
    );
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

  Widget _buildExercisesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercices',
                  style: AppTextStyles.subtitle(context),
                ),
                FloatingActionButton.small(
                  onPressed: _showAddExerciseDialog,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._exercises.map((exercise) => _buildExerciseCard(exercise)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.exercise.name,
                  style: AppTextStyles.cardTitle(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _showDeleteExerciseConfirmation(exercise),
                  color: colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Série ${index + 1}',
                      style: AppTextStyles.bodyBold(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _setDescription(set, exercise.exercise.type.name),
                        style: AppTextStyles.body(context),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (exercise.notes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Notes: ${exercise.notes}',
                  style: AppTextStyles.caption(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAddExerciseDialog() async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => const ExerciseSelectionDialog(),
    );

    if (result != null) {
      // Vérifier s'il y a des records pour cet exercice et afficher les suggestions
      final recordsAsync = ref.read(personalRecordsProvider);
      if (recordsAsync.hasValue) {
        final bestOneRM = WorkoutCalculatorService.findBestOneRM(recordsAsync.value!, result.id, exerciseName: result.name);
        if (bestOneRM != null && bestOneRM > 0) {
          await _showWorkoutSuggestionsForExercise(result, bestOneRM);
        }
      }
      
      setState(() {
        _exercises.add(WorkoutExercise(
          exercise: result,
          sets: [],
        ));
        _markAsModified();
      });
    }
  }

  Future<void> _showWorkoutSuggestionsForExercise(Exercise exercise, double oneRM) async {
    TrainingObjective selectedObjective = TrainingObjective.hypertrophie;
    UserLevel selectedLevel = UserLevel.intermediaire;
    int? targetRPE;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Suggestions d\'entraînement',
              style: AppTextStyles.title(context),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${exercise.name} - 1RM: ${oneRM.toStringAsFixed(1)} kg',
                    style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sélection de l'objectif
                  Text('Objectif d\'entraînement:', style: AppTextStyles.label(context)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TrainingObjective>(
                    value: selectedObjective,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: TrainingObjective.values.map((obj) => DropdownMenuItem(
                      value: obj,
                      child: Text(_getObjectiveName(obj)),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedObjective = value!),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sélection du niveau
                  Text('Niveau:', style: AppTextStyles.label(context)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserLevel>(
                    value: selectedLevel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: UserLevel.values.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(_getLevelName(level)),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedLevel = value!),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // RPE optionnel
                  Text('RPE cible (optionnel):', style: AppTextStyles.label(context)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    value: targetRPE,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Aucun')),
                      ...List.generate(5, (index) => DropdownMenuItem(
                        value: index + 6,
                        child: Text('RPE ${index + 6}'),
                      )),
                    ],
                    onChanged: (value) => setState(() => targetRPE = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Affichage des suggestions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggestions:',
                          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionCard(
                          context,
                          WorkoutCalculatorService.generateExerciseSuggestion(
                            exercise: exercise,
                            oneRM: oneRM,
                            objective: selectedObjective,
                            level: selectedLevel,
                            targetRPE: targetRPE,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Ignorer', style: AppTextStyles.button(context)),
              ),
              FilledButton(
                onPressed: () {
                  // Ajouter automatiquement les séries suggérées
                  final suggestion = WorkoutCalculatorService.generateExerciseSuggestion(
                    exercise: exercise,
                    oneRM: oneRM,
                    objective: selectedObjective,
                    level: selectedLevel,
                    targetRPE: targetRPE,
                  );
                  
                  final suggestedSets = List.generate(suggestion.suggestedSets, (index) => WorkoutSet(
                    repetitions: suggestion.suggestedReps,
                    weight: suggestion.suggestedWeight,
                    rpe: targetRPE ?? 0,
                    notes: null,
                  ));
                  
                  setState(() {
                    _exercises.add(WorkoutExercise(
                      exercise: exercise,
                      sets: suggestedSets,
                    ));
                    _markAsModified();
                  });
                  
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: 'Exercice ajouté avec ${suggestion.suggestedSets} séries suggérées',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
                child: Text('Utiliser les suggestions', style: AppTextStyles.button(context)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, ExerciseSuggestion suggestion) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      color: colorScheme.primaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recommend, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Suggestion pour 1 série',
                  style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSuggestionRow(context, 'Charge', '${suggestion.suggestedWeight.toStringAsFixed(1)} kg'),
            _buildSuggestionRow(context, 'Répétitions', '${suggestion.suggestedReps} reps'),
            _buildSuggestionRow(context, '% 1RM', '${suggestion.percentageOfOneRM.toStringAsFixed(1)}%'),
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

  void _showDeleteExerciseConfirmation(WorkoutExercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer l\'exercice',
          style: AppTextStyles.title(context),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ${exercise.exercise.name} ?',
          style: AppTextStyles.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.button(context),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _exercises.remove(exercise);
                _markAsModified();
              });
              Navigator.pop(context);
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: AppTextStyles.subtitle(context),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Ajoutez des notes sur votre séance...',
                hintStyle: AppTextStyles.inputHint(context),
              ),
              maxLines: 3,
              style: AppTextStyles.input(context),
              onChanged: (value) => _notesController.text = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ressenti général',
              style: AppTextStyles.subtitle(context),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _overallFeeling,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Sélectionnez votre ressenti',
                hintStyle: AppTextStyles.inputHint(context),
              ),
              items: List.generate(10, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                    '${index + 1}/10',
                    style: AppTextStyles.input(context),
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _overallFeeling = value);
                  _markAsModified();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveWorkout() {
    if (!_formKey.currentState!.validate()) return;
    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      exercises: _exercises,
      type: _selectedType,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      cardioEntry: _cardioEntry,
      overallFeeling: _overallFeeling,
      name: _nameController.text.isEmpty ? 'Séance ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}' : _nameController.text,
    );
    ref.read(workoutNotifierProvider.notifier).addWorkout(workout);
    final router = GoRouter.of(context);
    router.pop();
    Fluttertoast.showToast(
      msg: 'Séance enregistrée avec succès !',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }
}

// Dialogues pour la création d'exercices et de séries
class ExerciseSelectionDialog extends ConsumerWidget {
  const ExerciseSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExercises = ref.watch(exerciseNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = TextEditingController();
    ExerciseType? selectedType;
    List<Exercise> filteredExercises = allExercises;

    return StatefulBuilder(
      builder: (context, setState) {
        void filter() {
          setState(() {
            filteredExercises = allExercises.where((ex) {
              final matchesName = searchController.text.isEmpty || ex.name.toLowerCase().contains(searchController.text.toLowerCase());
              final matchesType = selectedType == null || ex.type == selectedType;
              return matchesName && matchesType;
            }).toList();
          });
        }

        final typeItems = ExerciseType.values.map((e) => DropdownMenuItem<ExerciseType>(
          value: e,
          child: Text(e.name),
        )).toList();

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionner un exercice',
                  style: AppTextStyles.title(context),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (_) => filter(),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ExerciseType>(
                  value: selectedType,
                  items: ExerciseType.values.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: filteredExercises.isEmpty
                      ? const Center(child: Text('Aucun exercice trouvé'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = filteredExercises[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white, width: 1),
                              ),
                              child: ListTile(
                                title: Text(
                                  exercise.name,
                                  style: AppTextStyles.body(context),
                                ),
                                subtitle: Text(exercise.type.name),
                                onTap: () => Navigator.pop(context, exercise),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SetCreationDialog extends ConsumerStatefulWidget {
  final Exercise exercise;
  const SetCreationDialog({super.key, required this.exercise});

  @override
  ConsumerState<SetCreationDialog> createState() => _SetCreationDialogState();
}

class _SetCreationDialogState extends ConsumerState<SetCreationDialog> {
  final List<WorkoutSet> _sets = [];
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _rpeController = TextEditingController();
  final _notesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();
  final _speedController = TextEditingController();
  final _pauseController = TextEditingController();
  final _hyroxDistanceController = TextEditingController();
  final _hyroxTimeController = TextEditingController();
  final _hyroxWeightTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ajouter des séries',
                  style: AppTextStyles.title(context),
                ),
                const SizedBox(height: 24),
                ..._buildFieldsForType(widget.exercise.type.name),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 24, bottom: 12),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une série'),
                          onPressed: _addSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.exercise.type == ExerciseType.force || 
                          widget.exercise.type == ExerciseType.hypertrophie)
                        Consumer(
                          builder: (context, ref, child) {
                            final recordsAsync = ref.watch(personalRecordsProvider);
                            return IconButton(
                              icon: const Icon(Icons.lightbulb_outline),
                              onPressed: () {
                                recordsAsync.when(
                                  data: (records) {
                                    print('DEBUG: Records loaded in Consumer, count: ${records.length}');
                                    final bestOneRM = WorkoutCalculatorService.findBestOneRM(records, widget.exercise.id, exerciseName: widget.exercise.name);
                                    print('DEBUG: Best 1RM found in Consumer: $bestOneRM');
                                    
                                    if (bestOneRM != null && bestOneRM > 0) {
                                      _showSuggestionsDialog(bestOneRM);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'Aucun 1RM disponible pour cet exercice',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                      );
                                    }
                                  },
                                  loading: () {
                                    print('DEBUG: Records are loading in Consumer...');
                                    Fluttertoast.showToast(
                                      msg: 'Chargement des records...',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                    );
                                  },
                                  error: (error, stack) {
                                    print('DEBUG: Error loading records in Consumer: $error');
                                    Fluttertoast.showToast(
                                      msg: 'Erreur lors du chargement des records: $error',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                    );
                                  },
                                );
                              },
                              tooltip: 'Voir les suggestions',
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 2,
                                shadowColor: colorScheme.primary.withOpacity(0.3),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                if (_sets.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Séries ajoutées :', style: AppTextStyles.label(context)),
                      const SizedBox(height: 8),
                      ..._sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Text('Série ${index + 1}', style: AppTextStyles.bodyBold(context)),
                            subtitle: Text(_setDescription(set, widget.exercise.type.name)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() => _sets.removeAt(index)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Annuler',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (_sets.isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'Veuillez ajouter au moins une série avant de valider.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                            );
                            return;
                          }
                          Navigator.pop(context, _sets);
                        },
                        child: Text(
                          'Valider',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFieldsForType(String type) {
    switch (type) {
      case 'force':
      case 'hypertrophie':
        return [
          TextField(
            controller: _repsController,
            decoration: InputDecoration(labelText: 'Répétitions', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            decoration: InputDecoration(labelText: 'Charge (kg)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
      case 'endurance':
      case 'cardio':
        return [
          TextField(
            controller: _distanceController,
            decoration: InputDecoration(labelText: 'Distance (km)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _timeController,
            decoration: InputDecoration(labelText: 'Temps (min)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _speedController,
            decoration: InputDecoration(labelText: 'Vitesse (km/h)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
      case 'hyrox':
        return [
          TextField(
            controller: _hyroxDistanceController,
            decoration: InputDecoration(labelText: 'Distance (m, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hyroxTimeController,
            decoration: InputDecoration(labelText: 'Temps (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hyroxWeightTextController,
            decoration: InputDecoration(labelText: 'Charge (ex: 2x6, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _repsController,
            decoration: InputDecoration(labelText: 'Nombre de répétitions (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
      case 'autre':
        return [
          TextField(
            controller: _rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
    }
    return [];
  }

  String _setDescription(WorkoutSet set, String type) {
    List<String> parts = [];
    if (set.notes != null && set.notes!.startsWith('pause:')) {
      parts.add(set.notes!);
      return parts.join(' | ');
    }
    if (type == ExerciseType.hyrox.toString()) {
      if (set.rpe != 0) parts.add('Distance: ${set.rpe} m');
      if (set.repetitions != 0) parts.add('Répétitions: ${set.repetitions}');
      if (set.notes != null && set.notes!.isNotEmpty) {
        for (final notePart in set.notes!.split('|')) {
          final trimmed = notePart.trim();
          if (trimmed.isNotEmpty) parts.add(trimmed);
        }
      }
    } else {
      if (set.repetitions != 0) parts.add('${set.repetitions} reps');
      if (set.weight != 0) parts.add('${set.weight} kg');
      if (set.rpe != 0) parts.add('RPE: ${set.rpe}');
      if (set.notes != null && set.notes!.isNotEmpty) parts.add(set.notes!);
    }
    return parts.join(' | ');
  }

  String? _buildHyroxNotes() {
    List<String> parts = [];
    if (_hyroxTimeController.text.isNotEmpty) {
      parts.add('Temps: ${_hyroxTimeController.text}s');
    }
    if (_hyroxWeightTextController.text.isNotEmpty) {
      parts.add('Charge: ${_hyroxWeightTextController.text}');
    }
    if (_pauseController.text.isNotEmpty) {
      parts.add('Pause: ${_pauseController.text}s');
    }
    if (_notesController.text.isNotEmpty) {
      parts.add(_notesController.text);
    }
    return parts.isEmpty ? null : parts.join(' | ');
  }

  void _addSet() {
    final type = widget.exercise.type;
    if (_pauseController.text.isNotEmpty) {
      setState(() {
        _sets.add(WorkoutSet(
          repetitions: 0,
          weight: 0,
          rpe: 0,
          notes: 'pause: ${_pauseController.text} sec',
        ));
        _pauseController.clear();
      });
      return;
    }
    switch (type) {
      case ExerciseType.force:
      case ExerciseType.hypertrophie:
        if (_repsController.text.isEmpty || _weightController.text.isEmpty || _rpeController.text.isEmpty) return;
        setState(() {
          _sets.add(WorkoutSet(
            repetitions: int.parse(_repsController.text),
            weight: double.parse(_weightController.text),
            rpe: int.parse(_rpeController.text),
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ));
          _repsController.clear();
          _weightController.clear();
          _rpeController.clear();
          _notesController.clear();
        });
        break;
      case ExerciseType.endurance:
      case ExerciseType.cardio:
        if (_distanceController.text.isEmpty || _timeController.text.isEmpty || _speedController.text.isEmpty) return;
        setState(() {
          _sets.add(WorkoutSet(
            repetitions: int.parse(_timeController.text),
            weight: double.parse(_distanceController.text),
            rpe: int.tryParse(_speedController.text) ?? 0,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ));
          _distanceController.clear();
          _timeController.clear();
          _speedController.clear();
          _notesController.clear();
        });
        break;
      case ExerciseType.hyrox:
        if (_hyroxDistanceController.text.isEmpty && _hyroxTimeController.text.isEmpty && _hyroxWeightTextController.text.isEmpty && _notesController.text.isEmpty && _pauseController.text.isEmpty && _repsController.text.isEmpty) {
          Fluttertoast.showToast(
            msg: 'Veuillez remplir au moins un champ pour ajouter une série Hyrox.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          return;
        }
        setState(() {
          _sets.add(WorkoutSet(
            repetitions: _repsController.text.isNotEmpty ? int.parse(_repsController.text) : 0,
            weight: 0,
            rpe: _hyroxDistanceController.text.isNotEmpty ? int.tryParse(_hyroxDistanceController.text) ?? 0 : 0,
            notes: _buildHyroxNotes(),
          ));
          _hyroxDistanceController.clear();
          _hyroxTimeController.clear();
          _hyroxWeightTextController.clear();
          _pauseController.clear();
          _repsController.clear();
          _notesController.clear();
        });
        break;
      case ExerciseType.autre:
        setState(() {
          _sets.add(WorkoutSet(
            repetitions: 0,
            weight: 0,
            rpe: 0,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ));
          _notesController.clear();
        });
        break;
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _rpeController.dispose();
    _notesController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    _speedController.dispose();
    _pauseController.dispose();
    _hyroxDistanceController.dispose();
    _hyroxTimeController.dispose();
    _hyroxWeightTextController.dispose();
    super.dispose();
  }

  void _showSuggestionsDialog(double bestOneRM) {
    TrainingObjective selectedObjective = TrainingObjective.hypertrophie;
    UserLevel selectedLevel = UserLevel.intermediaire;
    int? targetRPE;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Suggestions de charge',
              style: AppTextStyles.title(context),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.exercise.name} - 1RM: ${bestOneRM.toStringAsFixed(1)} kg',
                    style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sélection de l'objectif
                  Text('Objectif d\'entraînement:', style: AppTextStyles.label(context)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TrainingObjective>(
                    value: selectedObjective,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: TrainingObjective.values.map((obj) => DropdownMenuItem(
                      value: obj,
                      child: Text(_getObjectiveName(obj)),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedObjective = value!),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sélection du niveau
                  Text('Niveau:', style: AppTextStyles.label(context)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserLevel>(
                    value: selectedLevel,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: UserLevel.values.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(_getLevelName(level)),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedLevel = value!),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // RPE optionnel
                  Text('RPE cible (optionnel):', style: AppTextStyles.label(context)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    value: targetRPE,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Aucun')),
                      ...List.generate(5, (index) => DropdownMenuItem(
                        value: index + 6,
                        child: Text('RPE ${index + 6}'),
                      )),
                    ],
                    onChanged: (value) => setState(() => targetRPE = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Affichage des suggestions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggestions:',
                          style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildSuggestionCard(
                          context,
                          WorkoutCalculatorService.generateExerciseSuggestion(
                            exercise: widget.exercise,
                            oneRM: bestOneRM,
                            objective: selectedObjective,
                            level: selectedLevel,
                            targetRPE: targetRPE,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer', style: AppTextStyles.button(context)),
              ),
              FilledButton(
                onPressed: () {
                  final suggestion = WorkoutCalculatorService.generateExerciseSuggestion(
                    exercise: widget.exercise,
                    oneRM: bestOneRM,
                    objective: selectedObjective,
                    level: selectedLevel,
                    targetRPE: targetRPE,
                  );
                  
                  // Remplir automatiquement les champs avec les suggestions
                  this.setState(() {
                    _repsController.text = suggestion.suggestedReps.toString();
                    _weightController.text = suggestion.suggestedWeight.toStringAsFixed(1);
                    if (targetRPE != null) {
                      _rpeController.text = targetRPE.toString();
                    }
                  });
                  
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: 'Champs remplis avec les suggestions',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
                child: Text('Utiliser les suggestions', style: AppTextStyles.button(context)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, ExerciseSuggestion suggestion) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      color: colorScheme.primaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recommend, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Suggestion pour 1 série',
                  style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSuggestionRow(context, 'Charge', '${suggestion.suggestedWeight.toStringAsFixed(1)} kg'),
            _buildSuggestionRow(context, 'Répétitions', '${suggestion.suggestedReps} reps'),
            _buildSuggestionRow(context, '% 1RM', '${suggestion.percentageOfOneRM.toStringAsFixed(1)}%'),
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

class CardioEntryDialog extends StatefulWidget {
  const CardioEntryDialog({super.key});

  @override
  State<CardioEntryDialog> createState() => _CardioEntryDialogState();
}

class _CardioEntryDialogState extends State<CardioEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _paceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isInterval = false;
  final List<IntervalSegment> _intervals = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une séance cardio'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une distance';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une durée';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _paceController,
                  decoration: const InputDecoration(labelText: 'Allure (min/km)'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Mode fractionné'),
                  value: _isInterval,
                  onChanged: (value) {
                    setState(() {
                      _isInterval = value;
                    });
                  },
                ),
                if (_isInterval) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addInterval,
                    child: const Text('Ajouter un intervalle'),
                  ),
                  ..._intervals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final interval = entry.value;
                    return ListTile(
                      title: Text('Intervalle ${index + 1}'),
                      subtitle: Text(
                        '${interval.duration}s - ${interval.isRunning ? "Course" : "Marche"}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeInterval(index),
                      ),
                    );
                  }),
                ],
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _saveCardio,
          child: const Text('Valider'),
        ),
      ],
    );
  }

  void _addInterval() async {
    final interval = await showDialog<IntervalSegment>(
      context: context,
      builder: (context) => const IntervalSegmentDialog(),
    );

    if (interval != null) {
      setState(() {
        _intervals.add(interval);
      });
    }
  }

  void _removeInterval(int index) {
    setState(() {
      _intervals.removeAt(index);
    });
  }

  void _saveCardio() {
    if (_formKey.currentState!.validate()) {
      final distance = double.parse(_distanceController.text);
      final duration = int.parse(_durationController.text);
      final pace = double.tryParse(_paceController.text);

      final cardio = CardioEntry(
        date: DateTime.now(),
        distance: distance,
        duration: duration,
        pace: pace,
        isInterval: _isInterval,
        intervals: _isInterval ? _intervals : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      Navigator.pop(context, cardio);
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    _paceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class IntervalSegmentDialog extends StatefulWidget {
  const IntervalSegmentDialog({super.key});

  @override
  State<IntervalSegmentDialog> createState() => _IntervalSegmentDialogState();
}

class _IntervalSegmentDialogState extends State<IntervalSegmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _paceController = TextEditingController();
  bool _isRunning = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un intervalle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Durée (secondes)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une durée';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _paceController,
                  decoration: const InputDecoration(labelText: 'Allure (min/km)'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Course'),
                  subtitle: const Text('Marche si désactivé'),
                  value: _isRunning,
                  onChanged: (value) {
                    setState(() {
                      _isRunning = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _saveInterval,
          child: const Text('Valider'),
        ),
      ],
    );
  }

  void _saveInterval() {
    if (_formKey.currentState!.validate()) {
      final duration = int.parse(_durationController.text);
      final pace = double.tryParse(_paceController.text);

      final interval = IntervalSegment(
        duration: duration,
        isRunning: _isRunning,
        pace: pace,
      );

      Navigator.pop(context, interval);
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _paceController.dispose();
    super.dispose();
  }
} 