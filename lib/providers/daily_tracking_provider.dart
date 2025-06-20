import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/daily_tracking.dart';

part 'daily_tracking_provider.g.dart';

@riverpod
class DailyTrackingNotifier extends _$DailyTrackingNotifier {
  late Box<DailyTracking> _box;

  @override
  Future<List<DailyTracking>> build() async {
    _box = await Hive.openBox<DailyTracking>('daily_tracking');
    return _box.values.toList();
  }

  Future<void> addTracking(DailyTracking tracking) async {
    await _box.add(tracking);
    state = AsyncValue.data(_box.values.toList());
  }

  Future<void> updateTracking(DailyTracking tracking) async {
    final existing = _box.values.firstWhere((t) => t.date == tracking.date);
    await existing.delete();
    await _box.add(tracking);
    state = AsyncValue.data(_box.values.toList());
  }

  Future<DailyTracking?> getTrackingForDate(DateTime date) async {
    try {
      return _box.values.firstWhere(
        (tracking) => tracking.date.year == date.year &&
            tracking.date.month == date.month &&
            tracking.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<DailyTracking>> getTrackingForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _box.values
        .where((tracking) =>
            tracking.date.isAfter(weekStart) && tracking.date.isBefore(weekEnd))
        .toList();
  }
} 