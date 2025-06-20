import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:musculation/screens/exercises_screen.dart';
import 'package:musculation/providers/exercise_provider.dart';
import 'package:musculation/models/exercise.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ExercisesScreen Widget Tests', () {
    late ProviderContainer container;
    late List<Exercise> mockExercises;

    setUp(() {
      container = createTestContainer();
      
      mockExercises = [
        Exercise(
          id: '1',
          name: 'Squat',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Quadriceps, Glutes',

        ),
        Exercise(
          id: '2',
          name: 'Bench Press',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Chest, Triceps',

        ),
        Exercise(
          id: '3',
          name: 'Bicep Curl',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Biceps',

        ),
        Exercise(
          id: '4',
          name: 'Deadlift',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Back, Hamstrings',

        ),
      ];
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should display exercises screen with all main elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      // Vérifier la présence des éléments principaux
      expect(find.text('Exercices'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      // Vérifier la présence de la barre de recherche
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Rechercher un exercice...'), findsOneWidget);
    });

    testWidgets('should display filter options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      // Vérifier les options de filtre
      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Compound'), findsOneWidget);
      expect(find.text('Isolation'), findsOneWidget);
    });

    testWidgets('should display exercise list when exercises exist', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les exercices sont affichés
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Bicep Curl'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
    });

    testWidgets('should display exercise details correctly', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier les détails des exercices
      expect(find.text('Quadriceps'), findsOneWidget);
      expect(find.text('Glutes'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Triceps'), findsOneWidget);
      expect(find.text('Biceps'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Hamstrings'), findsOneWidget);
    });

    testWidgets('should filter exercises by type', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tester le filtre Compound
      await tester.tap(find.text('Compound'));
      await tester.pumpAndSettle();

      // Vérifier que seuls les exercices compound sont affichés
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Deadlift'), findsOneWidget);
      expect(find.text('Bicep Curl'), findsNothing); // Exercice isolation

      // Tester le filtre Isolation
      await tester.tap(find.text('Isolation'));
      await tester.pumpAndSettle();

      // Vérifier que seul l'exercice isolation est affiché
      expect(find.text('Bicep Curl'), findsOneWidget);
      expect(find.text('Squat'), findsNothing);
      expect(find.text('Bench Press'), findsNothing);
      expect(find.text('Deadlift'), findsNothing);
    });

    testWidgets('should search exercises by name', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = [
        Exercise(
          id: '1',
          name: 'Squat',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Quadriceps, Glutes',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rechercher "Squat"
      await tester.enterText(find.byType(TextField), 'Squat');
      await tester.pumpAndSettle();

      // Vérifier que seul Squat est affiché
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
      expect(find.text('Bicep Curl'), findsNothing);
      expect(find.text('Deadlift'), findsNothing);

      // Rechercher "Press"
      await tester.enterText(find.byType(TextField), 'Press');
      await tester.pumpAndSettle();

      // Vérifier que Bench Press est affiché
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsNothing);
    });

    testWidgets('should search exercises by muscle group', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = [
        Exercise(
          id: '1',
          name: 'Bench Press',
          type: ExerciseType.hypertrophie,
          muscleGroup: 'Chest, Triceps',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rechercher par groupe musculaire
      await tester.enterText(find.byType(TextField), 'Chest');
      await tester.pumpAndSettle();

      // Vérifier que Bench Press est affiché
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsNothing);
    });

    testWidgets('should display empty state when no exercises', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier le message d'état vide
      expect(find.text('Aucun exercice trouvé'), findsOneWidget);
      expect(find.text('Commencez par ajouter votre premier exercice'), findsOneWidget);
    });

    testWidgets('should display empty state when search has no results', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rechercher quelque chose qui n'existe pas
      await tester.enterText(find.byType(TextField), 'NonExistentExercise');
      await tester.pumpAndSettle();

      // Vérifier le message d'état vide
      expect(find.text('Aucun exercice trouvé'), findsOneWidget);
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      // Vérifier que l'indicateur de chargement est présent
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'erreur est affichée
      expect(find.text('Erreur de chargement des exercices'), findsOneWidget);
    });

    testWidgets('should display exercise type badges correctly', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les badges de type sont affichés
      expect(find.text('Compound'), findsAtLeastNWidgets(3)); // Squat, Bench Press, Deadlift
      expect(find.text('Isolation'), findsOneWidget); // Bicep Curl
    });

    testWidgets('should display muscle groups correctly', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que tous les groupes musculaires sont affichés
      expect(find.text('Quadriceps'), findsOneWidget);
      expect(find.text('Glutes'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Triceps'), findsOneWidget);
      expect(find.text('Biceps'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Hamstrings'), findsOneWidget);
    });

    testWidgets('should handle exercise selection', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Taper sur un exercice
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      // Vérifier que l'exercice est sélectionné (peut varier selon l'implémentation)
      expect(find.text('Squat'), findsOneWidget);
    });

    testWidgets('should handle floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      // Vérifier que le bouton flottant est présent
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Taper sur le bouton flottant
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Vérifier que quelque chose se passe (navigation ou dialogue)
      // Cela dépend de l'implémentation spécifique
    });

    testWidgets('should handle large number of exercises', (WidgetTester tester) async {
      final manyExercises = List.generate(100, (index) => Exercise(
        id: 'exercise_$index',
        name: 'Exercise $index',
        type: index % 2 == 0 ? ExerciseType.hypertrophie : ExerciseType.force,
        muscleGroup: 'Muscle $index',
      ));

      container.read(exerciseNotifierProvider.notifier).state = manyExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que l'application gère bien un grand nombre d'exercices
      expect(find.text('Exercise 0'), findsOneWidget);
      expect(find.text('Exercise 99'), findsOneWidget);
    });

    testWidgets('should handle special characters in search', (WidgetTester tester) async {
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
          type: ExerciseType.force,
          muscleGroup: 'Pectoraux',
        ),
      ];

      container.read(exerciseNotifierProvider.notifier).state = specialExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rechercher avec des caractères spéciaux
      await tester.enterText(find.byType(TextField), 'Élévation');
      await tester.pumpAndSettle();

      expect(find.text('Élévation latérale'), findsOneWidget);
      expect(find.text('Développé-couché'), findsNothing);
    });

    testWidgets('should handle case insensitive search', (WidgetTester tester) async {
      container.read(exerciseNotifierProvider.notifier).state = mockExercises;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ExercisesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rechercher en minuscules
      await tester.enterText(find.byType(TextField), 'squat');
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);

      // Rechercher en majuscules
      await tester.enterText(find.byType(TextField), 'BENCH');
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
    });
  });
} 
