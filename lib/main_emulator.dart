import 'bootstrap.dart';

/// Entry point for Android emulator. Run with:
///
/// ```sh
/// flutter run -t lib/main_emulator.dart
/// ```
Future<void> main() async {
  await bootstrap(envFileName: '.env.emulator');
}
