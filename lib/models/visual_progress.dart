import 'package:hive/hive.dart';

part 'visual_progress.g.dart';

@HiveType(typeId: 4)
class VisualProgress extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String mediaPath; // Chemin vers la photo ou vidéo

  @HiveField(2)
  final bool isVideo;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final double? weight; // Poids du jour

  @HiveField(5)
  final Map<String, double>? measurements; // Mensurations optionnelles

  VisualProgress({
    required this.date,
    required this.mediaPath,
    required this.isVideo,
    this.notes,
    this.weight,
    this.measurements,
  });
} 