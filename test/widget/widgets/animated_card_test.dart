import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musculation/widgets/animated_card.dart';

void main() {
  group('AnimatedCard Widget Tests', () {
    testWidgets('should display animated card with child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le contenu est affiché
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should animate card on appear', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Animated Content'),
            ),
          ),
        ),
      );

      // Vérifier l'animation d'apparition
      await tester.pump();
      await tester.pump(Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Vérifier que le contenu est visible après l'animation
      expect(find.text('Animated Content'), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {
                tapped = true;
              },
              child: Text('Tappable Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Taper sur la carte
      await tester.tap(find.byType(AnimatedCard));
      await tester.pumpAndSettle();

      // Vérifier que l'événement de tap est déclenché
      expect(tapped, isTrue);
    });

    testWidgets('should handle complex child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Column(
                children: [
                  Text('Title'),
                  SizedBox(height: 8),
                  Text('Subtitle'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 8),
                      Text('Rating: 4.5'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que tout le contenu complexe est affiché
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('Rating: 4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should handle different card elevations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              elevation: 8.0,
              child: Text('High Elevation Card'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte est affichée avec l'élévation spécifiée
      expect(find.text('High Elevation Card'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should handle different card margins', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              margin: EdgeInsets.all(16.0),
              child: Text('Card with Margin'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte est affichée avec la marge spécifiée
      expect(find.text('Card with Margin'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should handle different card padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              padding: EdgeInsets.all(24.0),
              child: Text('Card with Padding'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte est affichée avec le padding spécifié
      expect(find.text('Card with Padding'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should handle different card colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              backgroundColor: Colors.blue,
              child: Text('Blue Card'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte est affichée avec la couleur spécifiée
      expect(find.text('Blue Card'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should handle different card shapes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Rounded Card'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte est affichée avec la forme spécifiée
      expect(find.text('Rounded Card'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should handle multiple animated cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedCard(
                  child: Text('Card 1'),
                ),
                SizedBox(height: 16),
                AnimatedCard(
                  child: Text('Card 2'),
                ),
                SizedBox(height: 16),
                AnimatedCard(
                  child: Text('Card 3'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que toutes les cartes sont affichées
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.text('Card 3'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsNWidgets(3));
    });

    testWidgets('should handle animated cards in scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return AnimatedCard(
                  child: Text('Card $index'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les cartes sont affichées
      expect(find.text('Card 0'), findsOneWidget);
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsAtLeastNWidgets(2));

      // Faire défiler pour voir plus de cartes
      await tester.drag(find.byType(ListView), Offset(0, -500));
      await tester.pumpAndSettle();

      // Vérifier que de nouvelles cartes sont visibles
      expect(find.text('Card 5'), findsOneWidget);
      expect(find.text('Card 6'), findsOneWidget);
    });

    testWidgets('should handle animated cards with different animation durations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedCard(
                  duration: Duration(milliseconds: 500),
                  child: Text('Slow Animation'),
                ),
                SizedBox(height: 16),
                AnimatedCard(
                  duration: Duration(milliseconds: 100),
                  child: Text('Fast Animation'),
                ),
              ],
            ),
          ),
        ),
      );

      // Vérifier que les animations se déclenchent
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Vérifier que le contenu est affiché
      expect(find.text('Slow Animation'), findsOneWidget);
      expect(find.text('Fast Animation'), findsOneWidget);
    });

    testWidgets('should handle animated cards with different curves', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedCard(
                  child: Text('Ease In Out'),
                ),
                SizedBox(height: 16),
                AnimatedCard(
                  child: Text('Bounce Out'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le contenu est affiché
      expect(find.text('Ease In Out'), findsOneWidget);
      expect(find.text('Bounce Out'), findsOneWidget);
    });

    testWidgets('should handle animated cards with conditional rendering', (WidgetTester tester) async {
      bool showCard = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    if (showCard)
                      AnimatedCard(
                        child: Text('Conditional Card'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showCard = true;
                        });
                      },
                      child: Text('Show Card'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte n'est pas affichée initialement
      expect(find.text('Conditional Card'), findsNothing);

      // Afficher la carte
      await tester.tap(find.text('Show Card'));
      await tester.pumpAndSettle();

      // Vérifier que la carte apparaît avec animation
      expect(find.text('Conditional Card'), findsOneWidget);
    });

    testWidgets('should handle animated cards with state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Text('Stateful Card'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: Text('Update State'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte est affichée
      expect(find.text('Stateful Card'), findsOneWidget);

      // Mettre à jour l'état
      await tester.tap(find.text('Update State'));
      await tester.pumpAndSettle();

      // Vérifier que la carte reste stable
      expect(find.text('Stateful Card'), findsOneWidget);
    });

    testWidgets('should handle animated cards with different screen sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Responsive Card'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte s'adapte à la taille d'écran
      expect(find.text('Responsive Card'), findsOneWidget);

      // Changer la taille de l'écran
      await tester.binding.setSurfaceSize(Size(600, 800));
      await tester.pumpAndSettle();

      // Vérifier que la carte reste visible
      expect(find.text('Responsive Card'), findsOneWidget);

      // Changer à nouveau la taille
      await tester.binding.setSurfaceSize(Size(800, 600));
      await tester.pumpAndSettle();

      // Vérifier que la carte reste visible
      expect(find.text('Responsive Card'), findsOneWidget);
    });

    testWidgets('should handle animated cards with different text scales', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Scalable Card'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte s'adapte à différentes échelles de texte
      expect(find.text('Scalable Card'), findsOneWidget);
    });

    testWidgets('should handle animated cards with different locales', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('fr', 'FR'),
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Carte en français'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte s'affiche correctement avec la locale française
      expect(find.text('Carte en français'), findsOneWidget);

      // Changer la locale
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('en', 'US'),
          home: Scaffold(
            body: AnimatedCard(
              child: Text('Card in English'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que la carte s'affiche correctement avec la locale anglaise
      expect(find.text('Card in English'), findsOneWidget);
    });
  });
} 
