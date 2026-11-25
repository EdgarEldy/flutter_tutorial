import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/activate_account_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ActivateAccountUseCase useCase;
  late MockAuthRepository mockRepo;

  const fakeUser = User(
    id: 1,
    firstName: 'Alice',
    lastName: 'Martin',
    username: 'alicemartin',
    email: 'alice@test.com',
    enabled: true,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = ActivateAccountUseCase(mockRepo);
  });

  test('_01_ShouldReturnRight_WhenCodeIsExactlySixDigitsAndActivationSucceeds',
      () async {
    when(() => mockRepo.activateAccount(any(), any()))
        .thenAnswer((_) async => const Right(fakeUser));

    final result = await useCase('alice@test.com', '123456');

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (user) => expect(user.enabled, isTrue),
    );
    verify(() => mockRepo.activateAccount('alice@test.com', '123456')).called(1);
  });

  test('_02_ShouldReturnValidationFailure_WhenCodeHasFewerThanSixDigits',
      () async {
    final result = await useCase('alice@test.com', '12345');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
    verifyNever(() => mockRepo.activateAccount(any(), any()));
  });

  test('_03_ShouldReturnValidationFailure_WhenCodeHasMoreThanSixDigits',
      () async {
    final result = await useCase('alice@test.com', '1234567');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_04_ShouldReturnValidationFailure_WhenCodeContainsLetters', () async {
    final result = await useCase('alice@test.com', '12345A');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_05_ShouldReturnValidationFailure_WhenCodeIsEmpty', () async {
    final result = await useCase('alice@test.com', '');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_06_ShouldReturnServerFailure_WhenActivationCodeIsExpired', () async {
    when(() => mockRepo.activateAccount(any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Activation code expired', statusCode: 400)),
    );

    final result = await useCase('alice@test.com', '999999');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_07_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
    when(() => mockRepo.activateAccount(any(), any())).thenAnswer(
      (_) async => const Left(NetworkFailure()),
    );

    final result = await useCase('alice@test.com', '654321');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
