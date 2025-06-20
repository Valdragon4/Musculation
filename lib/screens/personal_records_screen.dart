import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/personal_record.dart';
import '../providers/personal_record_provider.dart';
import '../theme/text_styles.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../providers/exercise_provider.dart';
import '../services/workout_calculator_service.dart';
import 'package:go_router/go_router.dart';

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final recordsAsync = ref.watch(personalRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Records personnels',
          style: AppTextStyles.title(context),
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.white, width: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => context.push('/suggestions'),
            tooltip: 'Suggestions d\'entraînement',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(context, ref),
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun record enregistré',
                    style: AppTextStyles.body(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez votre premier record',
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRecordDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un record'),
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

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: records.map((record) => _buildRecordCard(context, record, ref)).toList(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context, ref),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, PersonalRecord record, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final allExercises = ref.watch(exerciseNotifierProvider);
    final exercise = allExercises.firstWhere((ex) => ex.id == record.exerciseId, orElse: () => Exercise(id: '', name: 'Exercice inconnu', muscleGroup: '', type: ExerciseType.autre));
    
    // Calculer le meilleur 1RM pour cet exercice
    final recordsAsync = ref.watch(personalRecordsProvider);
    double? bestOneRM;
    if (recordsAsync.hasValue) {
      bestOneRM = WorkoutCalculatorService.findBestOneRM(recordsAsync.value!, record.exerciseId, exerciseName: exercise.name);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: AppTextStyles.cardTitle(context),
                  ),
                ),
                if (bestOneRM != null && bestOneRM > 0)
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    onPressed: () => _showWorkoutSuggestions(context, exercise, bestOneRM!, ref),
                    color: colorScheme.primary,
                    tooltip: 'Voir les suggestions d\'entraînement',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _showDeleteConfirmation(context, record, ref),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bestOneRM != null && bestOneRM > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '1RM estimé: ${bestOneRM.toStringAsFixed(1)} kg',
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ...record.sets.asMap().entries.map((entry) => _buildRecordInfo(
              context,
              'Série ${entry.key + 1}',
              _setDescription(entry.value, exercise.type),
              Icons.fitness_center,
            )),
            const SizedBox(height: 8),
            _buildRecordInfo(
              context,
              'Date',
              _formatDate(record.date),
              Icons.calendar_today,
            ),
            if (record.notes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.notes!,
                  style: AppTextStyles.caption(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.label(context),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.body(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRecordDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final allExercises = ref.watch(exerciseNotifierProvider);
    Exercise? selectedExercise;
    List<WorkoutSet> sets = [];
    String? notes;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void addSet(WorkoutSet set) {
            setState(() => sets.add(set));
          }
          void removeSet(int index) {
            setState(() => sets.removeAt(index));
          }
          return AlertDialog(
            title: Text(
              'Nouveau record',
              style: AppTextStyles.title(context),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Exercise>(
                      value: selectedExercise,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Exercice',
                        labelStyle: AppTextStyles.label(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: allExercises.map((ex) => DropdownMenuItem(
                        value: ex,
                        child: Text(ex.name),
                      )).toList(),
                      onChanged: (ex) => setState(() => selectedExercise = ex),
                      validator: (value) => value == null ? 'Sélectionnez un exercice' : null,
                    ),
                    const SizedBox(height: 16),
                    if (selectedExercise != null)
                      _CompactSetInput(
                        type: selectedExercise!.type,
                        onAdd: addSet,
                      ),
                    if (sets.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Séries ajoutées :', style: AppTextStyles.label(context)),
                      ...sets.asMap().entries.map((entry) => ListTile(
                        title: Text('Série ${entry.key + 1}'),
                        subtitle: Text(_setDescription(entry.value, selectedExercise!.type)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removeSet(entry.key),
                        ),
                      )),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Notes (optionnel)',
                        labelStyle: AppTextStyles.label(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: AppTextStyles.input(context),
                      maxLines: 2,
                      onChanged: (value) => notes = value,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler', style: AppTextStyles.button(context)),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate() && selectedExercise != null && sets.isNotEmpty) {
                    ref.read(personalRecordsProvider.notifier).addRecord(
                      PersonalRecord(
                        exerciseId: selectedExercise!.id,
                        sets: sets,
                        date: DateTime.now(),
                        notes: notes,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Ajouter', style: AppTextStyles.button(context)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, PersonalRecord record, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le record',
          style: AppTextStyles.title(context),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ce record ?',
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(personalRecordsProvider.notifier).deleteRecord(record.key);
    }
  }

  Future<void> _showWorkoutSuggestions(BuildContext context, Exercise exercise, double oneRM, WidgetRef ref) async {
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
                child: Text('Fermer', style: AppTextStyles.button(context)),
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
                  '${suggestion.suggestedSets} séries',
                  style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSuggestionRow(context, 'Charge', '${suggestion.suggestedWeight.toStringAsFixed(1)} kg'),
            _buildSuggestionRow(context, 'Répétitions', '${suggestion.suggestedReps} reps'),
            _buildSuggestionRow(context, 'Repos', '${suggestion.suggestedRestTime} secondes'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}

// Widget compact pour ajouter une série selon le type d'exercice
class _CompactSetInput extends StatefulWidget {
  final ExerciseType type;
  final void Function(WorkoutSet) onAdd;
  const _CompactSetInput({required this.type, required this.onAdd});
  @override
  State<_CompactSetInput> createState() => _CompactSetInputState();
}

class _CompactSetInputState extends State<_CompactSetInput> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _rpeController = TextEditingController();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();
  final _speedController = TextEditingController();
  final _pauseController = TextEditingController();
  final _chargeTextController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Widget> fields;
    switch (widget.type) {
      case ExerciseType.force:
      case ExerciseType.hypertrophie:
        fields = [
          Row(children: [
            Expanded(child: TextField(controller: _repsController, decoration: const InputDecoration(labelText: 'Reps'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _weightController, decoration: const InputDecoration(labelText: 'Kg'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _rpeController, decoration: const InputDecoration(labelText: 'RPE'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optionnel)')),
        ]; break;
      case ExerciseType.cardio:
      case ExerciseType.endurance:
        fields = [
          Row(children: [
            Expanded(child: TextField(controller: _distanceController, decoration: const InputDecoration(labelText: 'Distance (km)'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _timeController, decoration: const InputDecoration(labelText: 'Temps (min)'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _speedController, decoration: const InputDecoration(labelText: 'Vitesse (km/h)'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _pauseController, decoration: const InputDecoration(labelText: 'Pause (secondes, optionnel)'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optionnel)')),
        ]; break;
      case ExerciseType.hyrox:
        fields = [
          Row(children: [
            Expanded(child: TextField(controller: _distanceController, decoration: const InputDecoration(labelText: 'Distance (m)'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _timeController, decoration: const InputDecoration(labelText: 'Temps (s)'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _repsController, decoration: const InputDecoration(labelText: 'Répétitions'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _chargeTextController, decoration: const InputDecoration(labelText: 'Charge (texte, optionnel)')),
          const SizedBox(height: 8),
          TextField(controller: _pauseController, decoration: const InputDecoration(labelText: 'Pause (secondes, optionnel)'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optionnel)')),
        ]; break;
      case ExerciseType.autre:
        fields = [
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes')), 
        ]; break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...fields,
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter la série'),
                onPressed: () {
                  switch (widget.type) {
                    case ExerciseType.force:
                    case ExerciseType.hypertrophie:
                      if (_repsController.text.isEmpty || _weightController.text.isEmpty) return;
                      widget.onAdd(WorkoutSet(
                        repetitions: int.parse(_repsController.text),
                        weight: double.parse(_weightController.text),
                        rpe: int.tryParse(_rpeController.text) ?? 0,
                        notes: _notesController.text.isEmpty ? null : _notesController.text,
                      ));
                      _repsController.clear(); _weightController.clear(); _rpeController.clear(); _notesController.clear();
                      break;
                    case ExerciseType.cardio:
                    case ExerciseType.endurance:
                      if (_distanceController.text.isEmpty || _timeController.text.isEmpty) return;
                      String? notes;
                      List<String> notesParts = [];
                      if (_pauseController.text.isNotEmpty) notesParts.add('Pause: ${_pauseController.text}s');
                      if (_notesController.text.isNotEmpty) notesParts.add(_notesController.text);
                      notes = notesParts.isEmpty ? null : notesParts.join(' | ');
                      widget.onAdd(WorkoutSet(
                        repetitions: int.parse(_timeController.text),
                        weight: double.parse(_distanceController.text),
                        rpe: int.tryParse(_speedController.text) ?? 0,
                        notes: notes,
                      ));
                      _distanceController.clear(); _timeController.clear(); _speedController.clear(); _pauseController.clear(); _notesController.clear();
                      break;
                    case ExerciseType.hyrox:
                      if (_distanceController.text.isEmpty && _timeController.text.isEmpty && _repsController.text.isEmpty && _chargeTextController.text.isEmpty && _pauseController.text.isEmpty && _notesController.text.isEmpty) return;
                      List<String> notesParts = [];
                      if (_timeController.text.isNotEmpty) notesParts.add('Temps: ${_timeController.text}s');
                      if (_chargeTextController.text.isNotEmpty) notesParts.add('Charge: ${_chargeTextController.text}');
                      if (_pauseController.text.isNotEmpty) notesParts.add('Pause: ${_pauseController.text}s');
                      if (_notesController.text.isNotEmpty) notesParts.add(_notesController.text);
                      String? notes = notesParts.isEmpty ? null : notesParts.join(' | ');
                      widget.onAdd(WorkoutSet(
                        repetitions: _repsController.text.isNotEmpty ? int.parse(_repsController.text) : 0,
                        weight: 0,
                        rpe: _distanceController.text.isNotEmpty ? int.tryParse(_distanceController.text) ?? 0 : 0,
                        notes: notes,
                      ));
                      _distanceController.clear(); _timeController.clear(); _repsController.clear(); _chargeTextController.clear(); _pauseController.clear(); _notesController.clear();
                      break;
                    case ExerciseType.autre:
                      widget.onAdd(WorkoutSet(repetitions: 0, weight: 0, rpe: 0, notes: _notesController.text.isEmpty ? null : _notesController.text));
                      _notesController.clear();
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _rpeController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    _speedController.dispose();
    _pauseController.dispose();
    _chargeTextController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 