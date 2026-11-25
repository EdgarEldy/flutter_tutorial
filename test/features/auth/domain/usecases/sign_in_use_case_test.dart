import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/core/storage/secure_token_storage.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/auth_tokens.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/sign_in_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepo;
  late MockSecureTokenStorage mockStorage;

  const fakeTokens = AuthTokens(
    accessToken: 'access-token-abc',
    refreshToken: 'refresh-token-xyz',
    expiresIn: 3600,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    mockStorage = MockSecureTokenStorage();
    useCase = SignInUseCase(mockRepo, mockStorage);

    when(
      () => mockStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
  });

  test('_01_ShouldReturnRight_WhenCredentialsAreValid', () async {
    when(() => mockRepo.signIn(any(), any()))
        .thenAnswer((_) async => const Right(fakeTokens));

    final result = await useCase('user@test.com', 'password123');

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('Expected Right'), (tokens) {
      expect(tokens.accessToken, equals('access-token-abc'));
      expect(tokens.refreshToken, equals('refresh-token-xyz'));
    });
    verify(() => mockRepo.signIn('user@test.com', 'password123')).called(1);
  });

  test('_02_ShouldSaveTokens_WhenSignInSucceeds', () async {
    when(() => mockRepo.signIn(any(), any()))
        .thenAnswer((_) async => const Right(fakeTokens));

    await useCase('user@test.com', 'password123');

    verify(
      () => mockStorage.saveTokens(
        accessToken: 'access-token-abc',
        refreshToken: 'refresh-token-xyz',
      ),
    ).called(1);
  });

  test('_03_ShouldReturnValidationFailure_WhenEmailIsBlank', () async {
    final result = await useCase('', 'password123');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
    verifyNever(() => mockRepo.signIn(any(), any()));
  });

  test('_04_ShouldReturnValidationFailure_WhenEmailContainsOnlyWhitespace',
      () async {
    final result = await useCase('   ', 'password123');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_05_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
    when(() => mockRepo.signIn(any(), any())).thenAnswer(
      (_) async => const Left(NetworkFailure('No connection')),
    );

    final result = await useCase('user@test.com', 'password123');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_06_ShouldReturnUnauthorizedFailure_WhenServerReturns401', () async {
    when(() => mockRepo.signIn(any(), any())).thenAnswer(
      (_) async => const Left(UnauthorizedFailure()),
    );

    final result = await useCase('user@test.com', 'wrong-password');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<UnauthorizedFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_07_ShouldNotSaveTokens_WhenSignInFails', () async {
    when(() => mockRepo.signIn(any(), any())).thenAnswer(
      (_) async => const Left(UnauthorizedFailure()),
    );

    await useCase('user@test.com', 'wrong-password');

    verifyNever(
      () => mockStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    );
  });

  test('_08_ShouldTrimEmail_WhenEmailHasLeadingTrailingSpaces', () async {
    when(() => mockRepo.signIn(any(), any()))
        .thenAnswer((_) async => const Right(fakeTokens));

    await useCase('  user@test.com  ', 'password123');

    verify(() => mockRepo.signIn('user@test.com', 'password123')).called(1);
  });
}
