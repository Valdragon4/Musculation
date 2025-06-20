import 'package:hive/hive.dart';

part 'cardio_entry.g.dart';

@HiveType(typeId: 5)
class CardioEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double distance; // en km

  @HiveField(2)
  final int duration; // en minutes

  @HiveField(3)
  final double? pace; // en min/km

  @HiveField(4)
  final bool isInterval;

  @HiveField(5)
  final List<IntervalSegment>? intervals;

  @HiveField(6)
  final String? notes;

  CardioEntry({
    required this.date,
    required this.distance,
    required this.duration,
    this.pace,
    this.isInterval = false,
    this.intervals,
    this.notes,
  });
}

@HiveType(typeId: 6)
class IntervalSegment {
  @HiveField(0)
  final int duration; // en secondes

  @HiveField(1)
  final bool isRunning; // true = course, false = marche

  @HiveField(2)
  final double? pace; // en min/km

  IntervalSegment({
    required this.duration,
    required this.isRunning,
    this.pace,
  });
} 