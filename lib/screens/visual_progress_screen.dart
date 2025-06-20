import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visual_progress.dart' as models;
import '../providers/visual_progress_provider.dart';
import '../services/image_service.dart';
import '../theme/text_styles.dart';
import 'dart:io';

class VisualProgressScreen extends ConsumerStatefulWidget {
  const VisualProgressScreen({super.key});

  @override
  ConsumerState<VisualProgressScreen> createState() => _VisualProgressScreenState();
}

class _VisualProgressScreenState extends ConsumerState<VisualProgressScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('Initialisation de VisualProgressScreen');
    _loadProgress();
    // Appeler la demande de permissions immédiatement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Demande des permissions après le premier frame');
      _requestPermissions();
    });
  }

  Future<void> _loadProgress() async {
    debugPrint('Chargement des données de progression');
    await ref.read(visualProgressNotifierProvider.notifier).build();
  }

  Future<void> _requestPermissions() async {
    debugPrint('Début de la demande des permissions');
    final imageService = ImageService();
    
    try {
      debugPrint('Appel de requestInitialPermissions');
      final hasPermissions = await imageService.requestInitialPermissions();
      debugPrint('Résultat de la demande de permissions: $hasPermissions');
      
      if (!hasPermissions && mounted) {
        debugPrint('Permissions non accordées, affichage du message d\'erreur');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les permissions nécessaires n\'ont pas été accordées'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('Permissions accordées avec succès');
      }
    } catch (e) {
      debugPrint('Erreur lors de la demande des permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la demande des permissions: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(visualProgressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progression',
          style: AppTextStyles.title(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => _showImageOptions(context),
          ),
        ],
      ),
      body: progressAsync.when(
        data: (progress) {
          if (progress.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Aucune progression enregistrée',
                    style: AppTextStyles.body(context),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showImageOptions(context),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Ajouter une photo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: progress.length,
            itemBuilder: (context, index) {
              final entry = progress[index];
              return _buildProgressCard(context, entry, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    try {
      debugPrint('Tentative de prise de photo');
      final imageService = ImageService();
      final imagePath = await imageService.takePhoto();
      
      if (imagePath != null && mounted) {
        debugPrint('Photo prise avec succès: $imagePath');
        await _showProgressDetailsDialog(imagePath);
      } else {
        debugPrint('Aucune photo prise');
      }
    } catch (e) {
      debugPrint('Erreur lors de la prise de photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      debugPrint('Tentative de sélection depuis la galerie');
      final imageService = ImageService();
      final imagePath = await imageService.pickImageFromGallery();
      
      if (imagePath != null && mounted) {
        debugPrint('Image sélectionnée avec succès: $imagePath');
        await _showProgressDetailsDialog(imagePath);
      } else {
        debugPrint('Aucune image sélectionnée');
      }
    } catch (e) {
      debugPrint('Erreur lors de la sélection depuis la galerie: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showProgressDetailsDialog(String imagePath) async {
    if (!mounted) return;

    final weightController = TextEditingController();
    final notesController = TextEditingController();
    final measurements = <String, double>{};

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        title: Text(
          'Détails du suivi',
          style: AppTextStyles.title(context),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aperçu de l'image
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Erreur lors de l\'aperçu: $error');
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Poids (kg)',
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Mensurations (optionnel)'),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tour de taille (cm)',
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
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final measurement = double.tryParse(value);
                  if (measurement != null) {
                    measurements['Tour de taille'] = measurement;
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tour de bras (cm)',
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
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final measurement = double.tryParse(value);
                  if (measurement != null) {
                    measurements['Tour de bras'] = measurement;
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tour de cuisse (cm)',
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
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final measurement = double.tryParse(value);
                  if (measurement != null) {
                    measurements['Tour de cuisse'] = measurement;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
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
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final progress = models.VisualProgress(
                date: DateTime.now(),
                mediaPath: imagePath,
                isVideo: false,
                weight: weight,
                measurements: measurements.isEmpty ? null : measurements,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              ref.read(visualProgressNotifierProvider.notifier).addProgress(progress);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suivi enregistré avec succès'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.white),
              ),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    models.VisualProgress entry,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!entry.isVideo)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.black,
                    insetPadding: EdgeInsets.zero,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: InteractiveViewer(
                        child: Center(
                          child: Image.file(
                            File(entry.mediaPath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(
                  File(entry.mediaPath),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${_formatDate(entry.date)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (entry.weight != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Poids: ${entry.weight} kg',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (entry.measurements != null && entry.measurements!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Mesures:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ...entry.measurements!.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        '${e.key}: ${e.value} cm',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      entry.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 