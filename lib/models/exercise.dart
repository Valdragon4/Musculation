import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'exercise.g.dart';

enum ExerciseType { force, cardio, hypertrophie, endurance, hyrox, autre }

class ExerciseTypeAdapter extends TypeAdapter<ExerciseType> {
  @override
  final int typeId = 99; // Choisir un typeId unique qui ne rentre pas en conflit

  @override
  ExerciseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseType.force;
      case 1:
        return ExerciseType.cardio;
      case 2:
        return ExerciseType.hypertrophie;
      case 3:
        return ExerciseType.endurance;
      case 4:
        return ExerciseType.hyrox;
      case 5:
        return ExerciseType.autre;
      default:
        return ExerciseType.autre;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseType obj) {
    switch (obj) {
      case ExerciseType.force:
        writer.writeByte(0);
        break;
      case ExerciseType.cardio:
        writer.writeByte(1);
        break;
      case ExerciseType.hypertrophie:
        writer.writeByte(2);
        break;
      case ExerciseType.endurance:
        writer.writeByte(3);
        break;
      case ExerciseType.hyrox:
        writer.writeByte(4);
        break;
      case ExerciseType.autre:
        writer.writeByte(5);
        break;
    }
  }
}

@HiveType(typeId: 8)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String muscleGroup;

  @HiveField(3)
  ExerciseType type;

  Exercise({
    String? id,
    required this.name,
    required this.muscleGroup,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  @override
  String toString() => name;
} 