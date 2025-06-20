import 'package:hive/hive.dart';

part 'daily_tracking.g.dart';

@HiveType(typeId: 7)
class DailyTracking extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int steps;

  @HiveField(2)
  final double waterIntake; // en litres

  @HiveField(3)
  final double? calories; // optionnel, pour future intégration API

  @HiveField(4)
  final String? notes;

  DailyTracking({
    required this.date,
    required this.steps,
    required this.waterIntake,
    this.calories,
    this.notes,
  });
} 