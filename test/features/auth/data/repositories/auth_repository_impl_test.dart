import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_tutorial/core/errors/failure.dart';
import 'package:flutter_tutorial/core/storage/secure_token_storage.dart';
import 'package:flutter_tutorial/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_tutorial/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_tutorial/features/auth/data/models/user_model.dart';
import 'package:flutter_tutorial/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/auth_tokens.dart';
import 'package:flutter_tutorial/features/auth/domain/entities/user.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

void main() {
  late AuthRepositoryImpl repo;
  late MockAuthRemoteDatasource mockDatasource;
  late MockSecureTokenStorage mockStorage;

  const fakeAuthResponse = AuthResponseModel(
    accessToken: 'access-token-abc',
    tokenType: 'Bearer',
    refreshToken: 'refresh-token-xyz',
    expiresIn: 3600,
  );

  const fakeUserModel = UserModel(
    id: 1,
    firstName: 'Alice',
    lastName: 'Martin',
    username: 'alicemartin',
    email: 'alice@test.com',
    enabled: true,
  );

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    mockStorage = MockSecureTokenStorage();
    repo = AuthRepositoryImpl(mockDatasource, mockStorage);
  });

  group('signIn', () {
    test('_01_ShouldReturnAuthTokens_WhenLoginSucceeds', () async {
      when(() => mockDatasource.login(any(), any()))
          .thenAnswer((_) async => fakeAuthResponse);

      final result = await repo.signIn('alice@test.com', 'Secret123');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (tokens) {
          expect(tokens, isA<AuthTokens>());
          expect(tokens.accessToken, equals('access-token-abc'));
          expect(tokens.refreshToken, equals('refresh-token-xyz'));
          expect(tokens.expiresIn, equals(3600));
        },
      );
    });

    test('_02_ShouldReturnUnauthorizedFailure_WhenServerReturns401', () async {
      final requestOptions = RequestOptions(path: 'api/v1/auth/login');
      when(() => mockDatasource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
            data: {'message': 'Unauthorized'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.signIn('alice@test.com', 'wrong-pass');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_03_ShouldReturnNetworkFailure_WhenConnectionTimesOut', () async {
      when(() => mockDatasource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/v1/auth/login'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        ),
      );

      final result = await repo.signIn('alice@test.com', 'Secret123');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('_04_ShouldReturnServerFailure_WhenServerReturns400', () async {
      final requestOptions = RequestOptions(path: 'api/v1/auth/login');
      when(() => mockDatasource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            requestOptions: requestOptions,
            data: {'message': 'Bad credentials'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.signIn('alice@test.com', 'Secret123');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f, isA<ServerFailure>());
          expect((f as ServerFailure).statusCode, equals(400));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('_05_ShouldReturnNetworkFailure_WhenConnectionIsRefused', () async {
      when(() => mockDatasource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/v1/auth/login'),
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        ),
      );

      final result = await repo.signIn('alice@test.com', 'Secret123');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('register', () {
    test('_01_ShouldReturnUser_WhenRegistrationSucceeds', () async {
      when(
        () => mockDatasource.register(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenAnswer((_) async => fakeUserModel);

      final result = await repo.register(
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
        (user) {
          expect(user, isA<User>());
          expect(user.email, equals('alice@test.com'));
        },
      );
    });

    test('_02_ShouldReturnNetworkFailure_WhenConnectionFails', () async {
      when(
        () => mockDatasource.register(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          username: any(named: 'username'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/v1/auth/register'),
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        ),
      );

      final result = await repo.register(
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
  });

  group('logout', () {
    test('_01_ShouldReturnRight_WhenServerLogoutSucceeds', () async {
      when(() => mockDatasource.logout()).thenAnswer((_) async {});

      final result = await repo.logout();

      expect(result.isRight(), isTrue);
    });

    test('_02_ShouldReturnNetworkFailure_WhenRequestFails', () async {
      when(() => mockDatasource.logout()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'api/v1/auth/logout'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repo.logout();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getMe', () {
    test('_01_ShouldReturnUser_WhenProfileFetchSucceeds', () async {
      when(() => mockDatasource.getMe())
          .thenAnswer((_) async => fakeUserModel);

      final result = await repo.getMe();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (user) {
          expect(user, isA<User>());
          expect(user.id, equals(1));
        },
      );
    });

    test('_02_ShouldReturnUnauthorizedFailure_WhenSessionIsExpired', () async {
      final requestOptions = RequestOptions(path: 'api/v1/auth/me');
      when(() => mockDatasource.getMe()).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.getMe();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<UnauthorizedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('activateAccount', () {
    test('_01_ShouldReturnUser_WhenActivationSucceeds', () async {
      when(() => mockDatasource.activateAccount(any(), any()))
          .thenAnswer((_) async => fakeUserModel);

      final result = await repo.activateAccount('alice@test.com', '123456');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (user) => expect(user.email, equals('alice@test.com')),
      );
    });

    test('_02_ShouldReturnServerFailure_WhenActivationCodeIsInvalid',
        () async {
      final requestOptions =
          RequestOptions(path: 'api/v1/auth/activate-account');
      when(() => mockDatasource.activateAccount(any(), any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            requestOptions: requestOptions,
            data: {'message': 'Invalid code'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repo.activateAccount('alice@test.com', '999999');

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('isLoggedIn', () {
    test('_01_ShouldReturnTrue_WhenAccessTokenExistsInStorage', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'valid-access-token');

      final result = await repo.isLoggedIn();

      expect(result, isTrue);
      verify(() => mockStorage.getAccessToken()).called(1);
    });

    test('_02_ShouldReturnFalse_WhenNoAccessTokenIsStored', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);

      final result = await repo.isLoggedIn();

      expect(result, isFalse);
    });
  });
}
