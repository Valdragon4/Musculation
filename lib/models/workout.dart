import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'exercise.dart';
import 'cardio_entry.dart';

part 'workout.g.dart';

@HiveType(typeId: 10)
enum WorkoutType {
  @HiveField(0)
  upperBody,
  @HiveField(1)
  lowerBody,
  @HiveField(2)
  fullBody,
  @HiveField(3)
  cardio,
  @HiveField(4)
  other
}

@HiveType(typeId: 1)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  final int repetitions;

  @HiveField(1)
  final double weight;

  @HiveField(2)
  final int rpe;

  @HiveField(3)
  final String? notes;

  WorkoutSet({
    required this.repetitions,
    required this.weight,
    required this.rpe,
    this.notes,
  });
}

@HiveType(typeId: 2)
class WorkoutExercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Exercise exercise;

  @HiveField(2)
  final List<WorkoutSet> sets;

  @HiveField(3)
  final String? notes;

  WorkoutExercise({
    String? id,
    required this.exercise,
    required this.sets,
    this.notes,
  }) : id = id ?? const Uuid().v4();
}

@HiveType(typeId: 11)
class Workout extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<WorkoutExercise> exercises;

  @HiveField(3)
  final WorkoutType type;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final CardioEntry? cardioEntry;

  @HiveField(6)
  final int? overallFeeling; // 1-10 scale

  @HiveField(7)
  final String name;

  Workout({
    String? id,
    required this.date,
    required this.exercises,
    required this.type,
    this.notes,
    this.cardioEntry,
    this.overallFeeling,
    required this.name,
  }) : id = id ?? const Uuid().v4();
} 