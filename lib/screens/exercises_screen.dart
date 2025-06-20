import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise.dart';
import '../theme/text_styles.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExercises = ref.watch(exerciseNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
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

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Exercices',
              style: AppTextStyles.title(context),
            ),
            shape: const Border(
              bottom: BorderSide(color: Colors.white, width: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddExerciseDialog(context, ref),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Filtrer par type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 1)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                      ),
                      items: [null, ...ExerciseType.values].map((type) {
                        if (type == null) {
                          return DropdownMenuItem<ExerciseType>(
                            value: null,
                            child: Text('Tous les types', style: AppTextStyles.body(context)),
                          );
                        }
                        return DropdownMenuItem<ExerciseType>(
                          value: type,
                          child: Text(type.name, style: AppTextStyles.body(context)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedType = value;
                        filter();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredExercises.isEmpty
                    ? const Center(child: Text('Aucun exercice enregistré'))
                    : ListView.builder(
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return ExerciseCard(
                            exercise: exercise,
                            onEdit: () => _showEditExerciseDialog(context, ref, exercise),
                            onDelete: () => _deleteExercise(context, ref, exercise),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddExerciseDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String muscleGroup = '';
    ExerciseType type = ExerciseType.autre;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nouvel exercice',
          style: AppTextStyles.title(context),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: AppTextStyles.label(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                style: AppTextStyles.input(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Groupe musculaire',
                  labelStyle: AppTextStyles.label(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                style: AppTextStyles.input(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un groupe musculaire';
                  }
                  return null;
                },
                onSaved: (value) => muscleGroup = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseType>(
                value: type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: AppTextStyles.label(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                style: AppTextStyles.input(context),
                items: ExerciseType.values.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(_exerciseTypeToString(e)),
                )).toList(),
                onChanged: (value) {
                  if (value != null) type = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un type';
                  }
                  return null;
                },
              ),
            ],
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
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                ref.read(exerciseNotifierProvider.notifier).addExercise(
                  Exercise(
                    name: name,
                    muscleGroup: muscleGroup,
                    type: type,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: Text(
              'Ajouter',
              style: AppTextStyles.button(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditExerciseDialog(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) async {
    final nameController = TextEditingController(text: exercise.name);
    final muscleGroupController = TextEditingController(text: exercise.muscleGroup);
    final typeController = TextEditingController(text: exercise.type.name);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'exercice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: muscleGroupController,
              decoration: const InputDecoration(labelText: 'Groupe musculaire'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type (force, cardio, etc.)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  muscleGroupController.text.isNotEmpty &&
                  typeController.text.isNotEmpty) {
                final updatedExercise = Exercise(
                  id: exercise.id,
                  name: nameController.text,
                  muscleGroup: muscleGroupController.text,
                  type: ExerciseType.values.byName(typeController.text),
                );
                ref.read(exerciseNotifierProvider.notifier).updateExercise(updatedExercise);
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer l\'exercice',
          style: AppTextStyles.title(context),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ${exercise.name} ?',
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
              'Supprimer',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(exerciseNotifierProvider.notifier).deleteExercise(exercise.id);
    }
  }

  String _exerciseTypeToString(ExerciseType type) {
    switch (type) {
      case ExerciseType.force:
        return 'Force';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.hypertrophie:
        return 'Hypertrophie';
      case ExerciseType.endurance:
        return 'Endurance';
      case ExerciseType.hyrox:
        return 'Hyrox';
      case ExerciseType.autre:
        return 'Autre';
    }
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(
                  exercise.name,
                  style: AppTextStyles.cardTitle(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  exercise.muscleGroup,
                  style: AppTextStyles.caption(context),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.category,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  exercise.type.name,
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 