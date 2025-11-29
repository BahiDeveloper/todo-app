# Todo App Professionnelle - Flutter

Une application de gestion de tâches moderne et professionnelle développée avec Flutter, démontrant les meilleures pratiques de développement mobile.

## ✨ Fonctionnalités

- ✅ **Gestion complète des tâches** - Créer, modifier, supprimer et marquer comme complétées
- 🎯 **Système de priorités** - 4 niveaux (Basse, Moyenne, Haute, Urgente)
- 📁 **Catégorisation** - Organiser les tâches par catégories personnalisées
- 📅 **Dates d'échéance** - Planifier et suivre les deadlines
- 🔍 **Filtres avancés** - Filtrer par statut et catégorie
- 📊 **Statistiques** - Vue d'ensemble de la progression
- 💾 **Persistance locale** - Données sauvegardées avec Isar Database
- 🎨 **UI moderne** - Design Material 3 avec thème clair/sombre
- 🌍 **Localisation** - Interface en français

## 🏗️ Architecture

Le projet suit une architecture propre et scalable :

```
lib/
├── models/              # Modèles de données (Isar entities)
│   └── todo.dart
├── services/            # Logique métier et accès aux données
│   └── database_service.dart
├── providers/           # State management (Provider)
│   └── todo_provider.dart
├── screens/             # Écrans de l'application
│   └── home_screen.dart
├── widgets/             # Composants réutilisables
│   ├── todo_card.dart
│   ├── add_todo_dialog.dart
│   ├── edit_todo_dialog.dart
│   ├── stats_card.dart
│   └── category_filter.dart
└── main.dart            # Point d'entrée
```

## 🛠️ Technologies utilisées

- **Flutter 3.9+** - Framework UI
- **Isar 3.1** - Base de données locale NoSQL ultra-rapide
- **Provider 6.1** - State management
- **Material 3** - Design system moderne
- **Dart 3.9** - Langage de programmation

## 📦 Installation

### Prérequis

- Flutter SDK 3.9+
- Dart SDK 3.9+

### Étapes

1. Cloner le repository
```bash
git clone [url-du-repo]
cd app_tuto
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Générer le code Isar
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Lancer l'application
```bash
flutter run
```

## 🚀 Utilisation

### Créer une tâche
1. Cliquer sur le bouton "Nouvelle tâche"
2. Remplir les informations (titre obligatoire)
3. Optionnel : ajouter description, priorité, catégorie, date d'échéance
4. Cliquer sur "Créer"

### Modifier une tâche
1. Cliquer sur une tâche dans la liste
2. Modifier les informations
3. Cliquer sur "Enregistrer"

### Filtrer les tâches
- Utiliser les chips de filtrage (Toutes/Actives/Complétées)
- Filtrer par catégorie via les chips horizontales

### Supprimer des tâches
- Bouton poubelle sur chaque tâche
- Menu "Supprimer les complétées" pour nettoyer en masse

## 📱 Screenshots

*À venir - captures d'écran de l'application*

## 🎓 Concepts Flutter démontrés

- **State Management** avec Provider
- **Database locale** avec Isar et code generation
- **Architecture en couches** (Models, Services, Providers, UI)
- **Widgets personnalisés** réutilisables
- **Material 3** et theming
- **Formulaires** avec validation
- **Dialogs** et modals
- **Filtrage** et recherche
- **Localisation** (i18n)
- **Gestion du cycle de vie** des widgets

## 🔄 Améliorations futures possibles

- [ ] Recherche par texte
- [ ] Notifications pour les deadlines
- [ ] Export/Import des données
- [ ] Synchronisation cloud
- [ ] Mode hors ligne
- [ ] Animations avancées
- [ ] Tests unitaires et d'intégration
- [ ] Thèmes personnalisés

## 👨‍💻 Auteur

Développé dans le cadre d'un portfolio professionnel pour démontrer les compétences en développement Flutter.

## 📄 Licence

Ce projet est libre d'utilisation à des fins éducatives et de démonstration.
