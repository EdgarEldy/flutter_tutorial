import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/features/auth/data/datasources/password_reset_remote_datasource.dart';
import 'package:flutter_tutorial/features/auth/data/repositories/password_reset_repository_impl.dart';

class MockPasswordResetRemoteDatasource extends Mock
    implements PasswordResetRemoteDatasource {}

void main() {
  late MockPasswordResetRemoteDatasource mockDatasource;
  late PasswordResetRepositoryImpl repo;

  setUp(() {
    mockDatasource = MockPasswordResetRemoteDatasource();
    repo = PasswordResetRepositoryImpl(mockDatasource);
  });

  group('sendOtp', () {
    test('_01_ShouldReturnRight_WhenOtpIsSentSuccessfully', () async {
      when(() => mockDatasource.sendOtp(any())).thenAnswer((_) async {});

      final result = await repo.sendOtp('user@test.com');

      expect(result.isRight(), isTrue);
    });

    test('_02_ShouldReturnServerFailure_WhenEmailIsNotFound', () async {
      final requestOptions =
          RequestOptions(path: 'api/v1/password-reset/mobile');
      when(() => mockDatasource.sendOtp(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            requestOptions: requestOptions,
            data: {'message': 'Email not found'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.sendOtp('unknown@test.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_03_ShouldReturnUnauthorizedFailure_WhenServerReturns401', () async {
      final requestOptions =
          RequestOptions(path: 'api/v1/password-reset/mobile');
      when(() => mockDatasource.sendOtp(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.sendOtp('user@test.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_04_ShouldReturnNetworkFailure_WhenConnectionTimesOut', () async {
      when(() => mockDatasource.sendOtp(any())).thenThrow(
        DioException(
          requestOptions:
              RequestOptions(path: 'api/v1/password-reset/mobile'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        ),
      );

      final result = await repo.sendOtp('user@test.com');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('verifyOtp', () {
    test('_01_ShouldReturnRight_WhenOtpIsValid', () async {
      when(() => mockDatasource.verifyOtp(any(), any()))
          .thenAnswer((_) async {});

      final result = await repo.verifyOtp('user@test.com', '123456');

      expect(result.isRight(), isTrue);
    });

    test('_02_ShouldReturnServerFailure_WhenOtpIsIncorrect', () async {
      final requestOptions =
          RequestOptions(path: 'api/v1/password-reset/verify-otp');
      when(() => mockDatasource.verifyOtp(any(), any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            requestOptions: requestOptions,
            data: {'message': 'Invalid OTP'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.verifyOtp('user@test.com', '000000');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_03_ShouldReturnNetworkFailure_WhenConnectionIsRefused', () async {
      when(() => mockDatasource.verifyOtp(any(), any())).thenThrow(
        DioException(
          requestOptions:
              RequestOptions(path: 'api/v1/password-reset/verify-otp'),
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        ),
      );

      final result = await repo.verifyOtp('user@test.com', '123456');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('confirmReset', () {
    test('_01_ShouldReturnRight_WhenPasswordResetIsConfirmed', () async {
      when(() => mockDatasource.confirmReset(any(), any(), any()))
          .thenAnswer((_) async {});

      final result =
          await repo.confirmReset('otp-123456', 'NewPass123!', 'NewPass123!');

      expect(result.isRight(), isTrue);
    });

    test('_02_ShouldReturnServerFailure_WhenOtpTokenIsExpired', () async {
      final requestOptions =
          RequestOptions(path: 'api/v1/password-reset/confirm');
      when(() => mockDatasource.confirmReset(any(), any(), any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            requestOptions: requestOptions,
            data: {'message': 'Token expired'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result =
          await repo.confirmReset('expired-otp', 'NewPass123!', 'NewPass123!');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_03_ShouldReturnUnauthorizedFailure_WhenServerReturns401', () async {
      final requestOptions =
          RequestOptions(path: 'api/v1/password-reset/confirm');
      when(() => mockDatasource.confirmReset(any(), any(), any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result =
          await repo.confirmReset('bad-otp', 'NewPass123!', 'NewPass123!');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_04_ShouldReturnNetworkFailure_WhenRequestTimesOut', () async {
      when(() => mockDatasource.confirmReset(any(), any(), any())).thenThrow(
        DioException(
          requestOptions:
              RequestOptions(path: 'api/v1/password-reset/confirm'),
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout',
        ),
      );

      final result =
          await repo.confirmReset('otp-123456', 'NewPass123!', 'NewPass123!');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
