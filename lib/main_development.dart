import 'bootstrap.dart';

/// Entry point for the `development` flavor. Run with:
///
/// ```sh
/// flutter run -t lib/main_development.dart --flavor development
/// ```
Future<void> main() async {
  await bootstrap(envFileName: '.env.development');
}
