import 'dart:io';
import 'package:hive/hive.dart';
import 'package:musculation/models/exercise.dart';
import 'package:musculation/models/personal_record.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/models/visual_progress.dart';

bool _adaptersRegistered = false;

Future<void> initHive() async {
  final tempDir = Directory.systemTemp.createTempSync();
  Hive.init(tempDir.path);
  
  // Enregistrer les adaptateurs une seule fois
  if (!_adaptersRegistered) {
    Hive.registerAdapter(ExerciseTypeAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(WorkoutSetAdapter());
    Hive.registerAdapter(PersonalRecordAdapter());
    Hive.registerAdapter(VisualProgressAdapter());
    _adaptersRegistered = true;
  }

  // Fermer toutes les boxes ouvertes
  await Hive.close();
  
  // Ouvrir les boxes nécessaires
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<Workout>('workouts');
  await Hive.openBox<PersonalRecord>('personal_records');
  await Hive.openBox<VisualProgress>('visual_progress');
}

Future<void> cleanupHive() async {
  await Hive.close();
  await Hive.deleteFromDisk();
} 
