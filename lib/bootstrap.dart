// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/tutorial_app.dart';

Future<void> bootstrap({required String envFileName}) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: envFileName);
    runApp(const ProviderScope(child: TutorialApp()));
  } catch (error) {
    runApp(_StartupErrorApp(message: error.toString()));
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to start the app:\n$message',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
