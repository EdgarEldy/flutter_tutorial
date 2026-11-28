# Flutter Development Environment Setup

This guide installs the tools required to compile, run and test Flutter Tutorial on Windows.

---

## Prerequisites

| Tool | Recommended version | Purpose |
|---|---|---|
| Flutter SDK | 3.13 or newer | Dart/Flutter builds |
| Dart SDK | included with Flutter | Analysis and formatting |
| Android SDK | API 36 | Android builds |
| Chrome | recent | Web validation |
| Git | recent | Branch workflow |
| Java | 17 | Android toolchain |

## Install Flutter

Download Flutter from `https://docs.flutter.dev/get-started/install`, extract it outside protected folders and add `flutter\bin` to `PATH`.

```powershell
flutter --version
flutter doctor
flutter doctor -v
```

Resolve Android, Chrome, Windows or Visual Studio warnings before launching the app.

## Start the backend

Flutter Tutorial expects `spring-boot-tutorial` at `http://localhost:8080` for local Web and desktop development.

```powershell
.\gradlew bootRun
```

Check the active base URL in `.env`, `.env.development`, `.env.emulator`, `.env.production` or `.env.web`.

Every base URL must end with `/`.

## Install dependencies

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Run the app

```powershell
flutter run -t lib/main_development.dart
flutter run -t lib/main_emulator.dart
flutter run -t lib/main_web.dart -d chrome
flutter run
```

## Test

```powershell
flutter test
flutter test --coverage
flutter analyze
```
