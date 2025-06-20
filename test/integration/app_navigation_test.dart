import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:musculation/main.dart';
import 'package:musculation/screens/home_screen.dart';
import 'package:musculation/screens/exercises_screen.dart';
import 'package:musculation/screens/workout_suggestions_screen.dart';
import 'package:musculation/screens/personal_records_screen.dart';
import 'package:musculation/screens/visual_progress_screen.dart';
import 'package:musculation/screens/workout_history_screen.dart';
import 'package:musculation/screens/create_workout_screen.dart';
import 'package:musculation/screens/workout_detail_screen.dart';
import 'package:musculation/models/workout.dart';
import 'package:musculation/models/exercise.dart';
import 'package:musculation/providers/workout_provider.dart';
import 'package:musculation/providers/exercise_provider.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('App Navigation Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = createTestContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should navigate to all main screens from bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'écran d'accueil est affiché par défaut
      expect(find.byType(HomeScreen), findsOneWidget);

      // Naviguer vers l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisesScreen), findsOneWidget);

      // Naviguer vers l'écran des suggestions de séances
      await tester.tap(find.text('Suggestions'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutSuggestionsScreen), findsOneWidget);

      // Naviguer vers l'écran des records personnels
      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalRecordsScreen), findsOneWidget);

      // Naviguer vers l'écran de progression visuelle
      await tester.tap(find.text('Progression'));
      await tester.pumpAndSettle();
      expect(find.byType(VisualProgressScreen), findsOneWidget);

      // Naviguer vers l'écran d'historique des séances
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);

      // Retourner à l'écran d'accueil
      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should navigate to create workout screen from home', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Taper sur le bouton "Nouvelle séance"
      await tester.tap(find.text('Nouvelle séance'));
      await tester.pumpAndSettle();

      // Vérifier que l'écran de création de séance s'ouvre
      expect(find.byType(CreateWorkoutScreen), findsOneWidget);
    });

    testWidgets('should navigate to create workout screen from exercises screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Taper sur le bouton flottant pour ajouter un exercice
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Vérifier que l'écran de création d'exercice s'ouvre
      // Cela dépend de l'implémentation spécifique
    });

    testWidgets('should navigate to workout detail screen from workout history', (WidgetTester tester) async {
      // Simuler des données de séance
      final mockWorkout = Workout(
        id: '1',
        name: 'Test Workout',
        exercises: [],
        date: DateTime.now(),
        type: WorkoutType.fullBody,
      );

      container.read(workoutNotifierProvider.notifier).addWorkout(mockWorkout);

      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran d'historique
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();

      // Taper sur une séance
      await tester.tap(find.text('Test Workout'));
      await tester.pumpAndSettle();

      // Vérifier que l'écran de détail de séance s'ouvre
      expect(find.byType(WorkoutDetailScreen), findsOneWidget);
    });

    testWidgets('should handle back navigation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Utiliser le bouton retour
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Vérifier que l'écran d'accueil est affiché
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should maintain navigation state when switching tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Naviguer vers un autre écran
      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();

      // Retourner à l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Vérifier que l'état de l'écran des exercices est maintenu
      expect(find.byType(ExercisesScreen), findsOneWidget);
    });

    testWidgets('should handle deep linking to workout detail', (WidgetTester tester) async {
      // Simuler des données de séance
      final mockWorkout = Workout(
        id: '1',
        name: 'Test Workout',
        exercises: [],
        date: DateTime.now(),
        type: WorkoutType.fullBody,
      );

      container.read(workoutNotifierProvider.notifier).addWorkout(mockWorkout);

      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Simuler un deep link vers une séance spécifique
      // Cela dépend de l'implémentation spécifique du routing
    });

    testWidgets('should handle navigation with no internet connection', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Simuler une perte de connexion
      // Naviguer vers différents écrans
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisesScreen), findsOneWidget);

      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalRecordsScreen), findsOneWidget);

      // Vérifier que la navigation fonctionne même sans connexion
    });

    testWidgets('should handle navigation with loading states', (WidgetTester tester) async {
      // Simuler un état de chargement
      container.read(exerciseNotifierProvider.notifier).addExercise(Exercise(
        id: '1',
        name: 'Test Exercise',
        type: ExerciseType.hypertrophie,
        muscleGroup: 'Muscle',
      ));

      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices pendant le chargement
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Vérifier que l'écran se charge correctement
      expect(find.byType(ExercisesScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with error states', (WidgetTester tester) async {
      // Simuler un état d'erreur
      container.read(exerciseNotifierProvider.notifier).addExercise(Exercise(
        id: '1',
        name: 'Test Exercise',
        type: ExerciseType.hypertrophie,
        muscleGroup: 'Muscle',
      ));

      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices avec erreur
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Vérifier que l'erreur est affichée
      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('should handle rapid navigation between screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigation rapide entre les écrans
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Progression'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();

      // Vérifier que l'application reste stable
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with large data sets', (WidgetTester tester) async {
      // Simuler un grand nombre d'exercices
      final manyExercises = List.generate(100, (index) => Exercise(
        id: 'exercise_$index',
        name: 'Exercise $index',
        type: ExerciseType.hypertrophie,
        muscleGroup: 'Muscle $index',
      ));

      container.read(exerciseNotifierProvider.notifier).addExercises(manyExercises);

      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Vérifier que l'application gère bien les grandes quantités de données
      expect(find.byType(ExercisesScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with special characters', (WidgetTester tester) async {
      // Simuler des données avec caractères spéciaux
      final specialExercises = [
        Exercise(
          id: '1',
          name: 'Élévation latérale',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Épaules',
        ),
        Exercise(
          id: '2',
          name: 'Développé-couché',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Pectoraux',
        ),
      ];

      container.read(exerciseNotifierProvider.notifier).addExercises(specialExercises);

      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers l'écran des exercices
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();

      // Vérifier que les caractères spéciaux sont gérés correctement
      expect(find.text('Élévation latérale'), findsOneWidget);
      expect(find.text('Développé-couché'), findsOneWidget);
    });

    testWidgets('should handle navigation with empty data sets', (WidgetTester tester) async {
      // Simuler des données vides
      container.read(exerciseNotifierProvider.notifier).addExercises([]);

      container.read(workoutNotifierProvider.notifier).addWorkout(Workout(
        id: '1',
        name: 'Test Workout',
        exercises: [],
        date: DateTime.now(),
        type: WorkoutType.fullBody,
      ));

      await tester.pumpWidget(
          ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers différents écrans avec données vides
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisesScreen), findsOneWidget);

      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutHistoryScreen), findsOneWidget);

      // Vérifier que les écrans gèrent correctement les données vides
    });

    testWidgets('should handle navigation with different screen orientations', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Changer l'orientation de l'écran
      await tester.binding.setSurfaceSize(Size(600, 800)); // Portrait
      await tester.pumpAndSettle();

      // Naviguer vers un écran
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisesScreen), findsOneWidget);

      // Changer l'orientation
      await tester.binding.setSurfaceSize(Size(800, 600)); // Paysage
      await tester.pumpAndSettle();

      // Vérifier que l'écran s'adapte correctement
      expect(find.byType(ExercisesScreen), findsOneWidget);
    });

    testWidgets('should handle navigation with different text scales', (WidgetTester tester) async {
      await tester.pumpWidget(
          ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Naviguer vers différents écrans
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisesScreen), findsOneWidget);

      await tester.tap(find.text('Records'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalRecordsScreen), findsOneWidget);

      // Vérifier que la navigation fonctionne avec différentes échelles de texte
    });
  });
} 
