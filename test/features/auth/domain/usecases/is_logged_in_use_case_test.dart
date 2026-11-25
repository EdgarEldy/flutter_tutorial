import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/is_logged_in_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late IsLoggedInUseCase useCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = IsLoggedInUseCase(mockRepo);
  });

  test('_01_ShouldReturnRightTrue_WhenValidAccessTokenIsStored', () async {
    when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (loggedIn) => expect(loggedIn, isTrue),
    );
    verify(() => mockRepo.isLoggedIn()).called(1);
  });

  test('_02_ShouldReturnRightFalse_WhenNoAccessTokenIsStored', () async {
    when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => false);

    final result = await useCase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right'),
      (loggedIn) => expect(loggedIn, isFalse),
    );
  });

  test('_03_ShouldReturnCacheFailure_WhenRepositoryThrowsException', () async {
    when(() => mockRepo.isLoggedIn())
        .thenThrow(Exception('Secure storage unavailable'));

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<CacheFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
