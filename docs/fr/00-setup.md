# Mise en place de l'environnement Flutter

Ce guide installe les outils nécessaires pour compiler, exécuter et tester Flutter Tutorial sur Windows.

---

## Prérequis

| Outil | Version recommandée | Usage |
|---|---|---|
| Flutter SDK | 3.13 ou plus récent | Compilation Dart/Flutter |
| Dart SDK | fourni avec Flutter | Analyse et formatage |
| Android SDK | API 36 | Applications Android |
| Chrome | récent | Validation Web |
| Git | récent | Branches et merges |
| Java | 17 | Toolchain Android |

## Installer Flutter

Télécharger Flutter depuis `https://docs.flutter.dev/get-started/install`, extraire le SDK hors des dossiers protégés, puis ajouter `flutter\bin` à `PATH`.

Vérifier l'installation :

```powershell
flutter --version
flutter doctor
flutter doctor -v
```

Résoudre les avertissements liés à Android, Chrome, Windows ou Visual Studio avant de lancer l'application.

## Démarrer le backend

Flutter Tutorial appelle `spring-boot-tutorial`. Le backend doit écouter sur `http://localhost:8080` pour les environnements Web et bureau.

```powershell
.\gradlew bootRun
```

Identifier la base URL active dans `.env`, `.env.development`, `.env.emulator`, `.env.production` ou `.env.web`.

Toutes les URL doivent se terminer par `/` pour que Dio résolve correctement les chemins API relatifs.

## Installer les dépendances

Depuis la racine du projet Flutter :

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Lancer l'application

```powershell
# Appareil physique ou Windows
flutter run -t lib/main_development.dart

# Émulateur Android
flutter run -t lib/main_emulator.dart

# Web
flutter run -t lib/main_web.dart -d chrome

# Point d'entrée par défaut
flutter run
```

## Tester

```powershell
flutter test
flutter test --coverage
flutter analyze
```

## Dépannage

| Symptôme | Solution |
|---|---|
| `BASE_URL` indisponible | Vérifier le fichier dotenv chargé par l'entrée principale |
| Asset `.env.web` introuvable | Ajouter `.env.web` dans `pubspec.yaml` sous `flutter.assets` |
| `Connection refused` sur l'émulateur | Utiliser l'adresse réseau du backend adaptée à l'émulateur |
| Erreur de build généré | Relancer `build_runner --delete-conflicting-outputs` |
| Erreurs sqflite sous Web | Utiliser le fallback mémoire pour les caches qui ne sont pas compatibles avec Web |
