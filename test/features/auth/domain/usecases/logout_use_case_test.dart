import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/core/storage/secure_token_storage.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/logout_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepo;
  late MockSecureTokenStorage mockStorage;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockStorage = MockSecureTokenStorage();
    useCase = LogoutUseCase(mockRepo, mockStorage);

    when(() => mockStorage.clearTokens()).thenAnswer((_) async {});
  });

  test('_01_ShouldReturnRightAndClearTokens_WhenLogoutSucceeds', () async {
    when(() => mockRepo.logout())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.logout()).called(1);
    verify(() => mockStorage.clearTokens()).called(1);
  });

  test('_02_ShouldClearTokens_WhenServerReturnsFailure', () async {
    when(() => mockRepo.logout()).thenAnswer(
      (_) async => const Left(NetworkFailure('Server unavailable')),
    );

    final result = await useCase();

    // Always returns Right(unit) regardless of server response
    expect(result.isRight(), isTrue);
    verify(() => mockStorage.clearTokens()).called(1);
  });

  test('_03_ShouldClearTokens_WhenServerReturnsUnauthorizedFailure', () async {
    when(() => mockRepo.logout()).thenAnswer(
      (_) async => const Left(UnauthorizedFailure()),
    );

    final result = await useCase();

    expect(result.isRight(), isTrue);
    verify(() => mockStorage.clearTokens()).called(1);
  });

  test('_04_ShouldCallRepositoryBeforeClearingTokens_WhenLogoutIsInvoked',
      () async {
    final callOrder = <String>[];
    when(() => mockRepo.logout()).thenAnswer((_) async {
      callOrder.add('logout');
      return const Right(unit);
    });
    when(() => mockStorage.clearTokens()).thenAnswer((_) async {
      callOrder.add('clearTokens');
    });

    await useCase();

    expect(callOrder, ['logout', 'clearTokens']);
  });
}
