import 'package:hive/hive.dart';
import 'workout.dart';

part 'personal_record.g.dart';

@HiveType(typeId: 3)
class PersonalRecord extends HiveObject {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final List<WorkoutSet> sets;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String? notes;

  PersonalRecord({
    required this.exerciseId,
    required this.sets,
    required this.date,
    this.notes,
  });
} 