import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/get_profile_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetProfileUseCase useCase;
  late MockAuthRepository mockRepo;

  const fakeUser = User(
    id: 42,
    firstName: 'Bob',
    lastName: 'Dupont',
    username: 'bobdupont',
    email: 'bob@test.com',
    enabled: true,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = GetProfileUseCase(mockRepo);
  });

  test('_01_ShouldReturnRight_WhenRepositoryReturnsProfile', () async {
    when(() => mockRepo.getMe())
        .thenAnswer((_) async => const Right(fakeUser));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (user) {
        expect(user.id, equals(42));
        expect(user.email, equals('bob@test.com'));
      },
    );
    verify(() => mockRepo.getMe()).called(1);
  });

  test('_02_ShouldReturnUnauthorizedFailure_WhenSessionIsExpired', () async {
    when(() => mockRepo.getMe()).thenAnswer(
      (_) async => const Left(UnauthorizedFailure()),
    );

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<UnauthorizedFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_03_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
    when(() => mockRepo.getMe()).thenAnswer(
      (_) async => const Left(NetworkFailure('Request timed out')),
    );

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
