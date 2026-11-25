// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// Placeholder widget for phase 1 scaffold (replaced in phase 2)
class _PlaceholderSignInPage extends StatelessWidget {
  const _PlaceholderSignInPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Sign In - Phase 2')),
    );
  }
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // authNotifierProvider will be defined in feature/auth.
  // For now, always allow navigation (unauthenticated state).
  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      // Auth guard will be wired up in phase 2 when authNotifierProvider is available.
      return null;
    },
    routes: [
      // Public routes: /sign-in, /register, /activate-account, /forgot-password, /verify-otp, /reset-password
      // Protected routes (bottom nav) via StatefulShellRoute.indexedStack: /products, /cart, /orders, /profile
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const _PlaceholderSignInPage(),
      ),
    ],
  );
}
