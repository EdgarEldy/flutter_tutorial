import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/auth_providers.dart';
import '../../domain/entities/auth_state.dart';

part 'auth_notifier.g.dart';

/// Global authentication state. `keepAlive: true` survives widget rebuilds.
/// Session check runs in [build]; the router guard watches this provider.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Session check is async; start with initial, then resolve
    _checkSession();
    return const AuthState.initial();
  }

  Future<void> _checkSession() async {
    final result = await ref.read(isLoggedInUseCaseProvider).call();
    result.fold(
      (_) => state = const AuthState.unauthenticated(),
      (loggedIn) {
        if (loggedIn) {
          state = const AuthState.authenticated(null);
          _loadProfile();
        } else {
          state = const AuthState.unauthenticated();
        }
      },
    );
  }

  Future<void> _loadProfile() async {
    final result = await ref.read(getProfileUseCaseProvider).call();
    result.fold(
      (_) {},
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    final result =
        await ref.read(signInUseCaseProvider).call(email, password);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) {
        state = const AuthState.authenticated(null);
        _loadProfile();
      },
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await ref.read(logoutUseCaseProvider).call();
    state = const AuthState.unauthenticated();
  }
}
