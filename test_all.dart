import 'package:flutter_test/flutter_test.dart';

// Import de tous les tests
import 'unit/services/workout_calculator_service_test.dart' as workout_calculator_test;
import 'unit/providers/exercise_provider_test.dart' as exercise_provider_test;
import 'unit/providers/personal_record_provider_test.dart' as personal_record_provider_test;
import 'widget/screens/home_screen_test.dart' as home_screen_test;
import 'widget/screens/exercises_screen_test.dart' as exercises_screen_test;
import 'widget/screens/workout_suggestions_screen_test.dart' as workout_suggestions_test;
import 'widget/screens/workout_history_screen_test.dart' as workout_history_test;
import 'widget/screens/personal_records_screen_test.dart' as personal_records_test;
import 'widget/screens/visual_progress_screen_test.dart' as visual_progress_test;
import 'widget/screens/create_workout_screen_test.dart' as create_workout_test;
import 'widget/screens/workout_detail_screen_test.dart' as workout_detail_test;
import 'widget/widgets/animated_card_test.dart' as animated_card_test;
import 'integration/app_navigation_test.dart' as app_navigation_test;

void main() {
  group('All Tests Suite', () {
    group('Unit Tests', () {
      group('Services', () {
        test('WorkoutCalculatorService', () {
          workout_calculator_test.main();
        });
      });

      group('Providers', () {
        test('ExerciseProvider', () {
          exercise_provider_test.main();
        });

        test('PersonalRecordProvider', () {
          personal_record_provider_test.main();
        });
      });
    });

    group('Widget Tests', () {
      group('Screens', () {
        test('HomeScreen', () {
          home_screen_test.main();
        });

        test('ExercisesScreen', () {
          exercises_screen_test.main();
        });

        test('WorkoutSuggestionsScreen', () {
          workout_suggestions_test.main();
        });

        test('WorkoutHistoryScreen', () {
          workout_history_test.main();
        });

        test('PersonalRecordsScreen', () {
          personal_records_test.main();
        });

        test('VisualProgressScreen', () {
          visual_progress_test.main();
        });

        test('CreateWorkoutScreen', () {
          create_workout_test.main();
        });

        test('WorkoutDetailScreen', () {
          workout_detail_test.main();
        });
      });

      group('Widgets', () {
        test('AnimatedCard', () {
          animated_card_test.main();
        });
      });
    });

    group('Integration Tests', () {
      test('App Navigation', () {
        app_navigation_test.main();
      });
    });
  });
} 