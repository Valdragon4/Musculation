import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import '../theme/text_styles.dart';
import 'package:go_router/go_router.dart';
import 'create_workout_screen.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  late DateTime selectedDate;
  late List<WorkoutExercise> exercises;
  late TextEditingController _nameController;
  bool _hasUnsavedChanges = false;
  int? _overallFeeling;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.workout.date;
    exercises = List.from(widget.workout.exercises);
    _nameController = TextEditingController(text: widget.workout.name);
    _overallFeeling = widget.workout.overallFeeling;
    _notesController = TextEditingController(text: widget.workout.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _markAsModified() {
    if (!_hasUnsavedChanges) {
      debugPrint('Marquage de la page comme modifiée');
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    debugPrint('WillPopScope onWillPop appelé');
    debugPrint('État des modifications: $_hasUnsavedChanges');
    
    if (!_hasUnsavedChanges) {
      debugPrint('Pas de modifications, navigation autorisée');
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

    debugPrint('Résultat du dialogue: $result');
    return result ?? false;
  }

  void _updateWorkout() {
    final updatedWorkout = Workout(
      id: widget.workout.id,
      date: selectedDate,
      exercises: exercises,
      type: widget.workout.type,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      cardioEntry: widget.workout.cardioEntry,
      overallFeeling: _overallFeeling,
      name: _nameController.text,
    );
    ref.read(workoutNotifierProvider.notifier).updateWorkout(updatedWorkout);
    setState(() {
      _hasUnsavedChanges = false;
      debugPrint('Workout mis à jour, _hasUnsavedChanges remis à false');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Séance modifiée avec succès !'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteWorkout() {
    ref.read(workoutNotifierProvider.notifier).deleteWorkout(widget.workout.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          debugPrint('Navigation retour autorisée');
          router.pop();
        } else {
          debugPrint('Navigation retour annulée');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Détails de la séance',
            style: AppTextStyles.title(context),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final router = GoRouter.of(context);
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                debugPrint('Navigation retour via bouton AppBar autorisée');
                router.pop();
              } else {
                debugPrint('Navigation retour via bouton AppBar annulée');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateWorkout,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom de la séance',
                    labelStyle: AppTextStyles.label(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white),
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
                Row(
                  children: [
                    Text(
                      'Date : ',
                      style: AppTextStyles.body(context),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            _markAsModified();
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                        style: AppTextStyles.bodyBold(context),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildWorkoutInfo(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercices',
                      style: AppTextStyles.subtitle(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddExerciseDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...exercises.map((exercise) => _buildExerciseCard(context, exercise)),
                const SizedBox(height: 24),
                _buildFeelingSection(context),
                if (widget.workout.notes != null || widget.workout.overallFeeling != null) ...[
                  const SizedBox(height: 24),
                  _buildNotesSection(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutInfo(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getWorkoutTypeName(widget.workout.type),
              style: AppTextStyles.cardTitle(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(widget.workout.date)}',
              style: AppTextStyles.body(context),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.workout.exercises.length} exercices',
              style: AppTextStyles.body(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutExercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              exercise.exercise.name,
              style: AppTextStyles.cardTitle(context),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditExerciseDialog(context, exercise),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteExerciseConfirmation(context, exercise),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...exercise.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
                            _setDescription(set, exercise.exercise.type),
                            style: AppTextStyles.body(context),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditSetDialog(context, exercise, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeSet(exercise, index),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddSetDialog(context, exercise),
                        icon: const Icon(Icons.add),
                        label: Text(
                          'Ajouter une série',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddPauseDialog(context, exercise),
                        icon: const Icon(Icons.timer),
                        label: Text(
                          'Ajouter une pause',
                          style: AppTextStyles.button(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes et ressenti',
              style: AppTextStyles.subtitle(context),
            ),
            const SizedBox(height: 16),
            if (widget.workout.notes != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.workout.notes!,
                  style: AppTextStyles.body(context),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.workout.overallFeeling != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ressenti: ${widget.workout.overallFeeling}/10',
                      style: AppTextStyles.body(context),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer la séance',
          style: AppTextStyles.title(context),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer cette séance ?',
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
              Navigator.pop(context);
              _deleteWorkout();
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

  String _getWorkoutTypeName(WorkoutType type) {
    switch (type) {
      case WorkoutType.upperBody:
        return 'Haut du corps';
      case WorkoutType.lowerBody:
        return 'Bas du corps';
      case WorkoutType.fullBody:
        return 'Corps complet';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.other:
        return 'Autre';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showAddExerciseDialog(BuildContext context) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => const ExerciseSelectionDialog(),
    );

    if (result != null) {
      setState(() {
        exercises.add(WorkoutExercise(
          exercise: result,
          sets: [],
        ));
        debugPrint('Exercice ajouté, marquage comme modifié');
        _markAsModified();
      });
    }
  }

  Future<void> _showEditExerciseDialog(BuildContext context, WorkoutExercise exercise) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => const ExerciseSelectionDialog(),
    );

    if (result != null) {
      setState(() {
        final index = exercises.indexOf(exercise);
        exercises[index] = WorkoutExercise(
          exercise: result,
          sets: exercise.sets,
        );
        _markAsModified();
      });
    }
  }

  void _showDeleteExerciseConfirmation(BuildContext context, WorkoutExercise exercise) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                'Supprimer l\'exercice',
                style: AppTextStyles.title(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Voulez-vous vraiment supprimer ${exercise.exercise.name} ?',
                style: AppTextStyles.body(context),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: AppTextStyles.button(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        exercises.remove(exercise);
                        _markAsModified();
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Supprimer',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSetDialog(BuildContext context, WorkoutExercise exercise) async {
    final result = await showDialog<List<WorkoutSet>>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajouter des séries',
                    style: AppTextStyles.title(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      debugPrint('Fermeture du dialogue d\'ajout de séries');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SetCreationDialog(exercise: exercise.exercise),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      debugPrint('Séries ajoutées: ${result.length}');
      setState(() {
        final index = exercises.indexOf(exercise);
        exercises[index] = WorkoutExercise(
          exercise: exercise.exercise,
          sets: [...exercise.sets, ...result],
        );
        _markAsModified();
      });
    }
  }

  Future<void> _showEditSetDialog(BuildContext context, WorkoutExercise exercise, int setIndex) async {
    final set = exercise.sets[setIndex];
    final repsController = TextEditingController(text: set.repetitions.toString());
    final weightController = TextEditingController(text: set.weight.toString());
    final rpeController = TextEditingController(text: set.rpe.toString());
    final notesController = TextEditingController(text: set.notes);
    final pauseController = TextEditingController();
    final distanceController = TextEditingController();
    final timeController = TextEditingController();
    final speedController = TextEditingController();
    final hyroxDistanceController = TextEditingController();
    final hyroxTimeController = TextEditingController();
    final hyroxWeightTextController = TextEditingController();

    // Pré-remplir les champs selon le type d'exercice
    if (exercise.exercise.type == ExerciseType.cardio || exercise.exercise.type == ExerciseType.endurance) {
      distanceController.text = set.weight.toString();
      timeController.text = set.repetitions.toString();
      speedController.text = ''; // La vitesse reste indépendante du RPE
    } else if (exercise.exercise.type == ExerciseType.hyrox) {
      hyroxDistanceController.text = set.rpe.toString();
      hyroxTimeController.text = set.repetitions.toString();
      hyroxWeightTextController.text = set.weight.toString();
    }

    final result = await showDialog<WorkoutSet>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Modifier la série',
          style: AppTextStyles.title(context),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildFieldsForType(exercise.exercise.type, 
              repsController, weightController, rpeController, notesController,
              pauseController, distanceController, timeController, speedController,
              hyroxDistanceController, hyroxTimeController, hyroxWeightTextController),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.button(context),
            ),
          ),
          FilledButton(
            onPressed: () {
              WorkoutSet newSet;
              
              if (exercise.exercise.type == ExerciseType.cardio || exercise.exercise.type == ExerciseType.endurance) {
                newSet = WorkoutSet(
                  repetitions: int.tryParse(timeController.text) ?? 0,
                  weight: double.tryParse(distanceController.text) ?? 0,
                  rpe: int.tryParse(rpeController.text) ?? 0,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
              } else if (exercise.exercise.type == ExerciseType.hyrox) {
                newSet = WorkoutSet(
                  repetitions: int.tryParse(hyroxTimeController.text) ?? 0,
                  weight: double.tryParse(hyroxWeightTextController.text) ?? 0,
                  rpe: int.tryParse(hyroxDistanceController.text) ?? 0,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
              } else {
                newSet = WorkoutSet(
                  repetitions: int.tryParse(repsController.text) ?? 0,
                  weight: double.tryParse(weightController.text) ?? 0,
                  rpe: int.tryParse(rpeController.text) ?? 0,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
              }
              
              Navigator.pop(context, newSet);
            },
            child: Text(
              'Enregistrer',
              style: AppTextStyles.button(context),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        final exerciseIndex = exercises.indexOf(exercise);
        final newSets = List<WorkoutSet>.from(exercise.sets);
        newSets[setIndex] = result;
        exercises[exerciseIndex] = WorkoutExercise(
          exercise: exercise.exercise,
          sets: newSets,
        );
        _markAsModified();
      });
    }
  }

  List<Widget> _buildFieldsForType(
    ExerciseType type,
    TextEditingController repsController,
    TextEditingController weightController,
    TextEditingController rpeController,
    TextEditingController notesController,
    TextEditingController pauseController,
    TextEditingController distanceController,
    TextEditingController timeController,
    TextEditingController speedController,
    TextEditingController hyroxDistanceController,
    TextEditingController hyroxTimeController,
    TextEditingController hyroxWeightTextController,
  ) {
    switch (type) {
      case ExerciseType.force:
      case ExerciseType.hypertrophie:
        return [
          TextField(
            controller: repsController,
            decoration: InputDecoration(labelText: 'Répétitions', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: weightController,
            decoration: InputDecoration(labelText: 'Charge (kg)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
      case ExerciseType.endurance:
      case ExerciseType.cardio:
        return [
          TextField(
            controller: distanceController,
            decoration: InputDecoration(labelText: 'Distance (km)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: timeController,
            decoration: InputDecoration(labelText: 'Temps (min)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: speedController,
            decoration: InputDecoration(labelText: 'Vitesse (km/h)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
      case ExerciseType.hyrox:
        return [
          TextField(
            controller: hyroxDistanceController,
            decoration: InputDecoration(labelText: 'Distance (m, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: hyroxTimeController,
            decoration: InputDecoration(labelText: 'Temps (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: hyroxWeightTextController,
            decoration: InputDecoration(labelText: 'Charge (ex: 2x6, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: repsController,
            decoration: InputDecoration(labelText: 'Nombre de répétitions (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
      case ExerciseType.autre:
        return [
          TextField(
            controller: rpeController,
            decoration: InputDecoration(labelText: 'RPE (optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pauseController,
            decoration: InputDecoration(labelText: 'Pause (secondes, optionnel)', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: InputDecoration(labelText: 'Notes', labelStyle: AppTextStyles.label(context)),
            style: AppTextStyles.input(context),
            maxLines: 3,
          ),
        ];
    }
  }

  void _removeSet(WorkoutExercise exercise, int setIndex) {
    setState(() {
      final index = exercises.indexOf(exercise);
      final newSets = List<WorkoutSet>.from(exercise.sets);
      newSets.removeAt(setIndex);
      exercises[index] = WorkoutExercise(
        exercise: exercise.exercise,
        sets: newSets,
      );
      _markAsModified();
    });
  }

  String _setDescription(WorkoutSet set, ExerciseType type) {
    List<String> parts = [];
    if (set.notes != null && set.notes!.startsWith('pause:')) {
      parts.add(set.notes!);
      return parts.join(' | ');
    }
    if (type == ExerciseType.hyrox) {
      final already = <String, bool>{};
      if (set.rpe != 0) {
        parts.add('Distance: ${set.rpe} m');
        already['distance'] = true;
      }
      if (set.repetitions != 0) {
        parts.add('Répétitions: ${set.repetitions}');
        already['reps'] = true;
      }
      if (set.weight != 0) {
        parts.add('Charge: ${set.weight} kg');
        already['charge'] = true;
      }
      if (set.notes != null && set.notes!.isNotEmpty) {
        for (final notePart in set.notes!.split('|')) {
          final trimmed = notePart.trim();
          if (trimmed.isEmpty) continue;
          if (trimmed.startsWith('Distance:') && already['distance'] == true) continue;
          if (trimmed.startsWith('Répétitions:') && already['reps'] == true) continue;
          if (trimmed.startsWith('Charge:') && already['charge'] == true) continue;
          parts.add(trimmed);
        }
      }
      return parts.join(' |\n');
    } else if (type == ExerciseType.cardio || type == ExerciseType.endurance) {
      if (set.weight != 0) parts.add('Distance: ${set.weight} km');
      if (set.repetitions != 0) parts.add('Temps: ${set.repetitions} min');
      if (set.rpe != 0) parts.add('Vitesse: ${set.rpe} km/h');
      if (set.notes != null && set.notes!.isNotEmpty) parts.add(set.notes!);
    } else {
      if (set.repetitions != 0) parts.add('${set.repetitions} reps');
      if (set.weight != 0) parts.add('${set.weight} kg');
      if (set.rpe != 0) parts.add('RPE: ${set.rpe}');
      if (set.notes != null && set.notes!.isNotEmpty) parts.add(set.notes!);
    }
    return parts.join(' | ');
  }

  Future<void> _showAddPauseDialog(BuildContext context, WorkoutExercise exercise) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une pause'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Durée de la pause (min)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        final index = exercises.indexOf(exercise);
        final newSets = List<WorkoutSet>.from(exercise.sets);
        newSets.add(WorkoutSet(
          repetitions: 0,
          weight: 0,
          rpe: 0,
          notes: 'pause: $result min',
        ));
        exercises[index] = WorkoutExercise(
          exercise: exercise.exercise,
          sets: newSets,
        );
        _markAsModified();
      });
    }
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
                setState(() {
                  _overallFeeling = value;
                  _markAsModified();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes sur la séance',
                labelStyle: AppTextStyles.label(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              style: AppTextStyles.input(context),
              maxLines: 3,
              onChanged: (_) => _markAsModified(),
            ),
          ],
        ),
      ),
    );
  }
} 