import 'bootstrap.dart';

/// Entry point for the `production` flavor. Run with:
///
/// ```sh
/// flutter run -t lib/main_production.dart --flavor production
/// ```
Future<void> main() async {
  await bootstrap(envFileName: '.env.production');
}
