import 'bootstrap.dart';

/// Entry point for Flutter Web. Run with:
///
/// ```sh
/// flutter run -t lib/main_web.dart -d chrome
/// ```
Future<void> main() async {
  await bootstrap(envFileName: '.env.web');
}
