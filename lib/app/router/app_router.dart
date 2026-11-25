import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/domain/entities/auth_state.dart';
import '../../features/auth/presentation/pages/activate_account_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';

part 'app_router.g.dart';

// Routes that do NOT require authentication
const _publicRoutes = [
  '/sign-in',
  '/register',
  '/activate-account',
  '/forgot-password',
  '/verify-otp',
  '/reset-password',
];

/// App router with an auth guard driven by [AuthNotifier].
/// Public routes bypass the guard; all others redirect to /sign-in when
/// the user is unauthenticated.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublic = _publicRoutes.any((r) => path.startsWith(r));

      final isAuthenticated = switch (authState) {
        AuthStateAuthenticated() => true,
        _ => false,
      };

      final isInitialOrLoading = switch (authState) {
        AuthStateInitial() || AuthStateLoading() => true,
        _ => false,
      };

      // During initial session check do not redirect yet
      if (isInitialOrLoading) return null;

      // Not authenticated and trying to access a protected route
      if (!isAuthenticated && !isPublic) return '/sign-in';

      // Authenticated and on a public (auth) route
      if (isAuthenticated && isPublic) return '/profile';

      return null;
    },
    routes: [
      // Public auth routes
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/activate-account',
        builder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? '';
          return ActivateAccountPage(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? '';
          return VerifyOtpPage(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordPage(otp: otp);
        },
      ),
      // Protected routes (phase 2 will add StatefulShellRoute for bottom nav)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
