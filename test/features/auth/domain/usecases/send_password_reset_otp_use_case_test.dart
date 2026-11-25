import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/domain/repositories/password_reset_repository.dart';
import 'package:flutter_tutorial/features/auth/domain/usecases/send_password_reset_otp_use_case.dart';

class MockPasswordResetRepository extends Mock
    implements PasswordResetRepository {}

void main() {
  late SendPasswordResetOtpUseCase useCase;
  late MockPasswordResetRepository mockRepo;

  setUp(() {
    mockRepo = MockPasswordResetRepository();
    useCase = SendPasswordResetOtpUseCase(mockRepo);
  });

  test('_01_ShouldReturnRight_WhenOtpIsSentSuccessfully', () async {
    when(() => mockRepo.sendOtp(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase('user@test.com');

    expect(result.isRight(), isTrue);
    verify(() => mockRepo.sendOtp('user@test.com')).called(1);
  });

  test('_02_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
    when(() => mockRepo.sendOtp(any())).thenAnswer(
      (_) async => const Left(NetworkFailure('No connection')),
    );

    final result = await useCase('user@test.com');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_03_ShouldReturnServerFailure_WhenEmailIsNotRegistered', () async {
    when(() => mockRepo.sendOtp(any())).thenAnswer(
      (_) async =>
          const Left(ServerFailure('Email not found', statusCode: 404)),
    );

    final result = await useCase('unknown@test.com');

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('_04_ShouldDelegateEmailToRepository_WhenUseCaseIsCalled', () async {
    when(() => mockRepo.sendOtp('exact@test.com'))
        .thenAnswer((_) async => const Right(unit));

    await useCase('exact@test.com');

    verify(() => mockRepo.sendOtp('exact@test.com')).called(1);
  });
}
