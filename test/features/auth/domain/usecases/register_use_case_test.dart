import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/register_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepo;

  const fakeUser = User(
    id: 1,
    firstName: 'Alice',
    lastName: 'Martin',
    username: 'alicemartin',
    email: 'alice@test.com',
    enabled: false,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = RegisterUseCase(mockRepo);
  });

  test('_01_ShouldReturnRight_WhenPasswordsMatchAndRegistrationSucceeds',
      () async {
    when(
      () => mockRepo.register(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    ).thenAnswer((_) async => const Right(fakeUser));

    final result = await useCase(
      firstName: 'Alice',
      lastName: 'Martin',
      username: 'alicemartin',
      email: 'alice@test.com',
      password: 'Secret123',
      confirmPassword: 'Secret123',
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (user) => expect(user.email, equals('alice@test.com')),
    );
  });

  test('_02_ShouldReturnValidationFailure_WhenPasswordsDoNotMatch', () async {
    final result = await useCase(
      firstName: 'Alice',
      lastName: 'Martin',
      username: 'alicemartin',
      email: 'alice@test.com',
      password: 'Secret123',
      confirmPassword: 'Different456',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left'),
    );
    verifyNever(
      () => mockRepo.register(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    );
  });

  test('_03_ShouldReturnNetworkFailure_WhenConnectionFails', () async {
    when(
      () => mockRepo.register(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    ).thenAnswer((_) async => const Left(NetworkFailure('No connection')));

    final result = await useCase(
      firstName: 'Alice',
      lastName: 'Martin',
      username: 'alicemartin',
      email: 'alice@test.com',
      password: 'Secret123',
      confirmPassword: 'Secret123',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_04_ShouldReturnServerFailure_WhenServerReturns400', () async {
    when(
      () => mockRepo.register(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    ).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Username already taken', statusCode: 400)),
    );

    final result = await useCase(
      firstName: 'Alice',
      lastName: 'Martin',
      username: 'alicemartin',
      email: 'alice@test.com',
      password: 'Secret123',
      confirmPassword: 'Secret123',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_05_ShouldDelegateAllFieldsToRepository_WhenPasswordsMatch', () async {
    when(
      () => mockRepo.register(
        firstName: 'Alice',
        lastName: 'Martin',
        username: 'alicemartin',
        email: 'alice@test.com',
        password: 'Secret123',
        confirmPassword: 'Secret123',
      ),
    ).thenAnswer((_) async => const Right(fakeUser));

    await useCase(
      firstName: 'Alice',
      lastName: 'Martin',
      username: 'alicemartin',
      email: 'alice@test.com',
      password: 'Secret123',
      confirmPassword: 'Secret123',
    );

    verify(
      () => mockRepo.register(
        firstName: 'Alice',
        lastName: 'Martin',
        username: 'alicemartin',
        email: 'alice@test.com',
        password: 'Secret123',
        confirmPassword: 'Secret123',
      ),
    ).called(1);
  });
}
