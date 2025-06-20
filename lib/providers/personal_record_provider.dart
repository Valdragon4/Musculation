import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/personal_record.dart';

part 'personal_record_provider.g.dart';

@riverpod
class PersonalRecords extends _$PersonalRecords {
  late Box<PersonalRecord> _box;

  @override
  Future<List<PersonalRecord>> build() async {
    _box = await Hive.openBox<PersonalRecord>('personal_records');
    return _box.values.toList();
  }

  Future<void> addRecord(PersonalRecord record) async {
    await _box.add(record);
    state = AsyncValue.data(_box.values.toList());
  }

  Future<void> deleteRecord(dynamic key) async {
    final record = _box.get(key);
    if (record != null) {
      await record.delete();
      state = AsyncValue.data(_box.values.toList());
    }
  }

  Future<List<PersonalRecord>> getRecordsForExercise(String exerciseId) async {
    return _box.values
        .where((record) => record.exerciseId == exerciseId)
        .toList();
  }
} 