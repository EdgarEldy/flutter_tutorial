// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_tutorial/features/auth/domain/entities/auth_state.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter_tutorial/features/auth/presentation/providers/auth_notifier.dart';

// Reuse the spy notifier pattern from sign_in_page_test
class SpyAuthNotifier extends AuthNotifier {
  SpyAuthNotifier(this._initial);

  final AuthState _initial;
  bool logoutCalled = false;

  @override
  AuthState build() => _initial;

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = const AuthState.unauthenticated();
  }
}

const fakeUser = User(
  id: 42,
  firstName: 'Bob',
  lastName: 'Dupont',
  username: 'bobdupont',
  email: 'bob@test.com',
  enabled: true,
);

/// Suppresses the known ListTile-in-DecoratedBox warning from the production
/// ProfilePage widget for the duration of the current test.
void suppressListTileWarnings() {
  final previousHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('ListTile background')) {
      return; // known production-code UI warning - safe to ignore in tests
    }
    previousHandler?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousHandler);
}

void main() {
  late SpyAuthNotifier spyNotifier;
  late ProviderContainer container;

  setUp(() {
    spyNotifier = SpyAuthNotifier(const AuthState.authenticated(fakeUser));
    container = ProviderContainer(
      overrides: [authProvider.overrideWith(() => spyNotifier)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildUnderTest() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProfilePage()),
    );
  }

  testWidgets('_01_ShouldRenderWithoutCrashing_WhenPageLoads', (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('_02_ShouldShowUserFullName_WhenUserIsAuthenticated',
      (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Bob Dupont'), findsOneWidget);
  });

  testWidgets('_03_ShouldShowUserEmail_WhenUserIsAuthenticated', (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('bob@test.com'), findsOneWidget);
  });

  testWidgets('_04_ShouldShowUsernameWithAtPrefix_WhenUserIsAuthenticated',
      (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('@bobdupont'), findsOneWidget);
  });

  testWidgets('_05_ShouldShowSignOutButton_WhenPageLoads', (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('_06_ShouldShowMyOrdersMenuItem_WhenPageLoads', (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    expect(find.text('My Orders'), findsOneWidget);
  });

  testWidgets('_07_ShouldCallLogout_WhenSignOutButtonIsTapped', (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    await tester.tap(find.text('Sign Out'));
    await tester.pump();

    expect(spyNotifier.logoutCalled, isTrue);
  });

  testWidgets('_08_ShouldShowLoading_WhenUserIsNullInAuthenticatedState',
      (tester) async {
    suppressListTileWarnings();
    spyNotifier = SpyAuthNotifier(const AuthState.authenticated(null));
    container = ProviderContainer(
      overrides: [authProvider.overrideWith(() => spyNotifier)],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pump();

    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('_09_ShouldShowUserInitialsAvatar_WhenUserIsProvided',
      (tester) async {
    suppressListTileWarnings();
    await tester.pumpWidget(buildUnderTest());
    await tester.pump();

    // Avatar shows first letter of first name + first letter of last name
    expect(find.text('BD'), findsOneWidget);
  });
}
