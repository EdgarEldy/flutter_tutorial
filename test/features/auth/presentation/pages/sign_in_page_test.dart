// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/auth/domain/entities/auth_state.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_tutorial/features/auth/presentation/providers/auth_notifier.dart';

// Spy notifier: records calls and controls state without real use cases
class SpyAuthNotifier extends AuthNotifier {
  SpyAuthNotifier([this._initial = const AuthState.unauthenticated()]);

  final AuthState _initial;
  String? capturedEmail;
  String? capturedPassword;
  bool logoutCalled = false;

  @override
  AuthState build() => _initial;

  @override
  Future<void> signIn(String email, String password) async {
    capturedEmail = email;
    capturedPassword = password;
    if (email.isEmpty) {
      state = const AuthState.error('Email is required');
    } else {
      state = const AuthState.authenticated(null);
    }
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = const AuthState.unauthenticated();
  }
}

Widget buildUnderTest({
  required ProviderContainer container,
  Widget child = const SignInPage(),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: child),
  );
}

void main() {
  late SpyAuthNotifier spyNotifier;
  late ProviderContainer container;

  setUp(() {
    spyNotifier = SpyAuthNotifier();
    container = ProviderContainer(
      overrides: [authProvider.overrideWith(() => spyNotifier)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.byType(SignInPage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowTutorialShopBranding_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.text('TutorialShop'), findsOneWidget);
  });

  testWidgets('_03_ShouldShowEmailAndPasswordFields_WhenPageLoads',
      (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  });

  testWidgets('_04_ShouldShowSignInButton_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('_05_ShouldShowForgotPasswordLink_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('_06_ShouldSetErrorState_WhenSignInIsTappedWithEmptyEmail',
      (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    // Tap the sign-in button without entering any text (email is empty)
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    // The spy notifier should have been called with empty email
    expect(spyNotifier.capturedEmail, equals(''));
    // And the state should be error
    expect(container.read(authProvider), isA<AuthStateError>());
  });

  testWidgets('_07_ShouldDisplayErrorMessage_WhenAuthStateIsError',
      (tester) async {
    spyNotifier = SpyAuthNotifier(const AuthState.error('Invalid credentials'));
    container = ProviderContainer(
      overrides: [authProvider.overrideWith(() => spyNotifier)],
    );

    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('_08_ShouldDisableSignInButton_WhenStateIsLoading',
      (tester) async {
    spyNotifier = SpyAuthNotifier(const AuthState.loading());
    container = ProviderContainer(
      overrides: [authProvider.overrideWith(() => spyNotifier)],
    );

    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    // Find the FilledButton - it should be disabled (onPressed is null when loading)
    final filledButton =
        tester.widget<FilledButton>(find.byType(FilledButton));
    expect(filledButton.onPressed, isNull);
  });

  testWidgets('_09_ShouldCallSignInWithEnteredCredentials_WhenSignInIsTapped',
      (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    // Find email and password fields by order in widget tree
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'user@test.com');
    await tester.enterText(textFields.last, 'Secret123');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(spyNotifier.capturedEmail, equals('user@test.com'));
    expect(spyNotifier.capturedPassword, equals('Secret123'));
  });

  testWidgets('_10_ShouldShowCreateAccountLink_WhenPageLoads', (tester) async {
    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('_11_ShouldRenderPageCorrectly_WhenUserIsAuthenticated',
      (tester) async {
    const fakeUser = User(
      id: 1,
      firstName: 'Alice',
      lastName: 'Martin',
      username: 'alicemartin',
      email: 'alice@test.com',
      enabled: true,
    );
    spyNotifier = SpyAuthNotifier(const AuthState.authenticated(fakeUser));
    container = ProviderContainer(
      overrides: [authProvider.overrideWith(() => spyNotifier)],
    );

    await tester.pumpWidget(buildUnderTest(container: container));
    await tester.pump();

    // No error shown when authenticated
    expect(find.byType(SignInPage), findsOneWidget);
  });
}
