import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/verify_password_reset_otp_use_case.dart';

class MockPasswordResetRepository extends Mock
    implements PasswordResetRepository {}

void main() {
  late VerifyPasswordResetOtpUseCase useCase;
  late MockPasswordResetRepository mockRepo;

  setUp(() {
    mockRepo = MockPasswordResetRepository();
    useCase = VerifyPasswordResetOtpUseCase(mockRepo);
  });

  test('_01_ShouldReturnRight_WhenOtpIsValid', () async {
    when(() => mockRepo.verifyOtp(any(), any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase('user@test.com', '123456');

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.verifyOtp('user@test.com', '123456')).called(1);
  });

  test('_02_ShouldReturnServerFailure_WhenOtpIsIncorrectOrExpired', () async {
    when(() => mockRepo.verifyOtp(any(), any())).thenAnswer(
      (_) async => const Left(ServerFailure('Invalid OTP', statusCode: 400)),
    );

    final result = await useCase('user@test.com', '000000');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_03_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
    when(() => mockRepo.verifyOtp(any(), any())).thenAnswer(
      (_) async => const Left(NetworkFailure()),
    );

    final result = await useCase('user@test.com', '123456');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_04_ShouldDelegateEmailAndOtpToRepository_WhenUseCaseIsCalled',
      () async {
    when(() => mockRepo.verifyOtp('exact@test.com', '654321'))
        .thenAnswer((_) async => const Right(unit));

    await useCase('exact@test.com', '654321');

    verify(() => mockRepo.verifyOtp('exact@test.com', '654321')).called(1);
  });
}
