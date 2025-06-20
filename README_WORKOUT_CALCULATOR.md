# Système de Calcul de Charges de Travail - Guide Utilisateur

## Vue d'ensemble

Le système de calcul de charges de travail de l'application de musculation utilise la formule d'Epley pour estimer le 1RM (One Repetition Maximum) et générer des suggestions d'entraînement personnalisées basées sur vos records personnels.

## Fonctionnalités principales

### 1. Calcul du 1RM
- **Formule utilisée** : 1RM = charge × (1 + 0.0333 × reps)
- Le système analyse automatiquement tous vos records personnels pour chaque exercice
- Il sélectionne le meilleur 1RM estimé pour générer les suggestions

### 2. Zones d'entraînement

#### Force
- **Pourcentage 1RM** : 85-100%
- **Répétitions** : 1-5
- **Séries** : 3-6
- **Temps de repos** : 180-300 secondes (3-5 minutes)

#### Hypertrophie
- **Pourcentage 1RM** : 65-80%
- **Répétitions** : 6-12
- **Séries** : 3-5
- **Temps de repos** : 60-120 secondes (1-2 minutes)

#### Endurance
- **Pourcentage 1RM** : 50-65%
- **Répétitions** : 12-20
- **Séries** : 2-4
- **Temps de repos** : 30-60 secondes

### 3. Ajustements selon le niveau

#### Débutant
- Réduction de 10% des pourcentages de charge
- Réduction de 20% du nombre de répétitions et séries
- Augmentation de 20% du temps de repos

#### Intermédiaire
- Aucun ajustement (valeurs standard)

#### Avancé
- Augmentation de 5% des pourcentages de charge
- Augmentation du nombre de séries
- Réduction de 10% du temps de repos

### 4. Ajustements RPE (Rate of Perceived Exertion)

Le système peut ajuster les charges selon le RPE cible :
- **RPE 6** (Très facile) : -15% de charge
- **RPE 7** (Facile) : -10% de charge
- **RPE 8** (Modéré, 2 reps en réserve) : -5% de charge
- **RPE 9** (Difficile, 1 rep en réserve) : Charge standard
- **RPE 10** (Maximum) : +5% de charge

## Utilisation dans l'application

### 1. Écran des Records Personnels
- Chaque record affiche le 1RM estimé
- Bouton d'ampoule pour voir les suggestions spécifiques à l'exercice
- Bouton dans l'AppBar pour accéder à toutes les suggestions

### 2. Création d'Entraînement
- Lors de l'ajout d'un exercice, suggestions automatiques si des records existent
- Possibilité d'utiliser les suggestions pour remplir automatiquement les séries
- Bouton d'ampoule dans l'ajout de séries pour les exercices force/hypertrophie

### 3. Écran de Suggestions Globales
- Vue d'ensemble de toutes les suggestions basées sur vos records
- Paramètres ajustables (objectif, niveau, RPE)
- Suggestions mises à jour en temps réel

## Comment obtenir les meilleures suggestions

1. **Ajoutez des records précis** : Plus vos records sont récents et précis, meilleures seront les suggestions
2. **Utilisez des charges variées** : Ayez des records avec différents nombres de répétitions pour une estimation plus précise
3. **Mettez à jour régulièrement** : Ajoutez de nouveaux records quand vous progressez
4. **Ajustez selon vos objectifs** : Changez l'objectif d'entraînement selon votre programme

## Limitations

- Le système ne fonctionne que pour les exercices de type "force" et "hypertrophie"
- Les suggestions sont basées sur des formules théoriques et doivent être adaptées à votre expérience
- Le RPE est subjectif et peut varier selon les conditions (fatigue, stress, etc.)

## Conseils d'utilisation

1. **Commencez progressivement** : Utilisez les suggestions comme point de départ, pas comme objectif absolu
2. **Écoutez votre corps** : Ajustez les charges selon vos sensations
3. **Progressez lentement** : Augmentez les charges de manière progressive
4. **Variez les objectifs** : Alternez entre force, hypertrophie et endurance pour un développement équilibré

## Support technique

Si vous rencontrez des problèmes ou avez des suggestions d'amélioration, n'hésitez pas à nous contacter. 