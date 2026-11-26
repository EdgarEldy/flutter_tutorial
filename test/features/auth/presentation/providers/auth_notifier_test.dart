import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/auth_state.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/auth_tokens.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/get_profile_use_case.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/is_logged_in_use_case.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_tutorial/features/auth/presentation/providers/auth_notifier.dart';

class MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

const fakeUser = User(
  id: 1,
  firstName: 'Alice',
  lastName: 'Martin',
  username: 'alicemartin',
  email: 'alice@test.com',
  enabled: true,
);

const fakeTokens = AuthTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresIn: 3600,
);

ProviderContainer buildContainer({
  required MockIsLoggedInUseCase isLoggedIn,
  required MockGetProfileUseCase getProfile,
  required MockSignInUseCase signIn,
  required MockLogoutUseCase logout,
}) {
  return ProviderContainer(
    overrides: [
      isLoggedInUseCaseProvider.overrideWithValue(isLoggedIn),
      getProfileUseCaseProvider.overrideWithValue(getProfile),
      signInUseCaseProvider.overrideWithValue(signIn),
      logoutUseCaseProvider.overrideWithValue(logout),
    ],
  );
}

void main() {
  late MockIsLoggedInUseCase mockIsLoggedIn;
  late MockGetProfileUseCase mockGetProfile;
  late MockSignInUseCase mockSignIn;
  late MockLogoutUseCase mockLogout;

  setUp(() {
    mockIsLoggedIn = MockIsLoggedInUseCase();
    mockGetProfile = MockGetProfileUseCase();
    mockSignIn = MockSignInUseCase();
    mockLogout = MockLogoutUseCase();
  });

  group('build / session check', () {
    test('_01_ShouldBeInitial_WhenNotifierIsFirstBuilt', () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(false));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      expect(container.read(authProvider), const AuthState.initial());
    });

    test('_02_ShouldBeUnauthenticated_WhenNoTokenIsStored', () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(false));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider), const AuthState.unauthenticated());
    });

    test('_03_ShouldBeAuthenticated_WhenTokenIsPresentAfterSessionCheck',
        () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(true));
      when(() => mockGetProfile.call())
          .thenAnswer((_) async => const Right(fakeUser));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state, isA<AuthStateAuthenticated>());
    });

    test('_04_ShouldBeAuthenticatedWithUser_WhenLoadProfileCompletes',
        () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(true));
      when(() => mockGetProfile.call())
          .thenAnswer((_) async => const Right(fakeUser));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state, isA<AuthStateAuthenticated>());
      final user = (state as AuthStateAuthenticated).user;
      expect(user?.email, equals('alice@test.com'));
    });

    test('_05_ShouldBeUnauthenticated_WhenSessionCheckFails', () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Left(CacheFailure('Storage error')));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider), const AuthState.unauthenticated());
    });
  });

  group('signIn', () {
    test(
        '_01_ShouldEmitLoadingThenAuthenticated_WhenSignInSucceeds',
        () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(false));
      when(() => mockSignIn.call(any(), any()))
          .thenAnswer((_) async => const Right(fakeTokens));
      when(() => mockGetProfile.call())
          .thenAnswer((_) async => const Right(fakeUser));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      final states = <AuthState>[];
      container.listen(authProvider, (_, next) => states.add(next));

      await container.read(authProvider.notifier).signIn(
            'alice@test.com',
            'Secret123',
          );

      expect(states, contains(const AuthState.loading()));
      expect(states, contains(const AuthState.authenticated(null)));
    });

    test('_02_ShouldEmitLoadingThenError_WhenSignInFails', () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(false));
      when(() => mockSignIn.call(any(), any())).thenAnswer(
        (_) async => const Left(UnauthorizedFailure()),
      );

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      await container
          .read(authProvider.notifier)
          .signIn('wrong@test.com', 'bad-pass');

      final state = container.read(authProvider);
      expect(state, isA<AuthStateError>());
    });

    test('_03_ShouldContainFailureMessage_WhenSignInFails', () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(false));
      when(() => mockSignIn.call(any(), any())).thenAnswer(
        (_) async => const Left(UnauthorizedFailure('Invalid credentials')),
      );

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      await container
          .read(authProvider.notifier)
          .signIn('wrong@test.com', 'bad-pass');

      final state = container.read(authProvider) as AuthStateError;
      expect(state.message, equals('Invalid credentials'));
    });
  });

  group('logout', () {
    test('_01_ShouldBeUnauthenticated_WhenLogoutIsCalled', () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(true));
      when(() => mockGetProfile.call())
          .thenAnswer((_) async => const Right(fakeUser));
      when(() => mockLogout.call())
          .thenAnswer((_) async => const Right(unit));

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider), const AuthState.unauthenticated());
    });

    test(
        '_02_ShouldBeUnauthenticated_WhenLogoutIsCalledEvenIfServerFails',
        () async {
      when(() => mockIsLoggedIn.call())
          .thenAnswer((_) async => const Right(false));
      when(() => mockLogout.call()).thenAnswer(
        (_) async => const Left(NetworkFailure('Server unavailable')),
      );

      final container = buildContainer(
        isLoggedIn: mockIsLoggedIn,
        getProfile: mockGetProfile,
        signIn: mockSignIn,
        logout: mockLogout,
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future<void>.delayed(Duration.zero);

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider), const AuthState.unauthenticated());
    });
  });
}
