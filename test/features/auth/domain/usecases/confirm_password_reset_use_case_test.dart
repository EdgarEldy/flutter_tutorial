import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/confirm_password_reset_use_case.dart';

class MockPasswordResetRepository extends Mock
    implements PasswordResetRepository {}

void main() {
  late ConfirmPasswordResetUseCase useCase;
  late MockPasswordResetRepository mockRepo;

  setUp(() {
    mockRepo = MockPasswordResetRepository();
    useCase = ConfirmPasswordResetUseCase(mockRepo);
  });

  test('_01_ShouldReturnRight_WhenResetIsConfirmedSuccessfully', () async {
    when(() => mockRepo.confirmReset(any(), any(), any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase('123456', 'NewPass123!', 'NewPass123!');

    expect(result.isRight(), isTrue);
    verify(
      () => mockRepo.confirmReset('123456', 'NewPass123!', 'NewPass123!'),
    ).called(1);
  });

  test('_02_ShouldReturnServerFailure_WhenOtpTokenIsExpiredOrInvalid',
      () async {
    when(() => mockRepo.confirmReset(any(), any(), any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Token expired', statusCode: 400)),
    );

    final result = await useCase('000000', 'NewPass123!', 'NewPass123!');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_03_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
    when(() => mockRepo.confirmReset(any(), any(), any())).thenAnswer(
      (_) async => const Left(NetworkFailure()),
    );

    final result = await useCase('123456', 'NewPass123!', 'NewPass123!');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_04_ShouldDelegateOtpAndPasswordsToRepository_WhenUseCaseIsCalled',
      () async {
    when(() => mockRepo.confirmReset('otp-val', 'pass1', 'pass1'))
        .thenAnswer((_) async => const Right(unit));

    await useCase('otp-val', 'pass1', 'pass1');

    verify(() => mockRepo.confirmReset('otp-val', 'pass1', 'pass1')).called(1);
  });
}
