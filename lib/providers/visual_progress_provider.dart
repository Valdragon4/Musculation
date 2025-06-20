import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/visual_progress.dart' as models;

part 'visual_progress_provider.g.dart';

@riverpod
class VisualProgressNotifier extends _$VisualProgressNotifier {
  late Box<models.VisualProgress> _box;

  @override
  Future<List<models.VisualProgress>> build() async {
    _box = await Hive.openBox<models.VisualProgress>('visual_progress');
    return _box.values.toList();
  }

  Future<void> addProgress(models.VisualProgress progress) async {
    try {
      print('Ajout d\'une nouvelle entrée de progression');
      print('Chemin de l\'image: ${progress.mediaPath}');
      print('Date: ${progress.date}');
      print('Poids: ${progress.weight}');
      print('Mensurations: ${progress.measurements}');
      print('Notes: ${progress.notes}');

      await _box.add(progress);
      state = AsyncValue.data(_box.values.toList());
      print('Entrée ajoutée avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'entrée: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteProgress(String id) async {
    try {
      final progress = _box.values.firstWhere((p) => p.key == id);
      await progress.delete();
      state = AsyncValue.data(_box.values.toList());
    } catch (e) {
      print('Erreur lors de la suppression de l\'entrée: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<List<models.VisualProgress>> getProgressForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _box.values
        .where((progress) =>
            progress.date.isAfter(weekStart) && progress.date.isBefore(weekEnd))
        .toList();
  }
} 