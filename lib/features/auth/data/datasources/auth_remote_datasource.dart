import 'package:dio/dio.dart';
import '../models/activate_account_request_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

/// Contract for remote auth data operations via the backend API.
///
/// Each method maps directly to one HTTP endpoint defined in the OpenAPI spec
/// under /api/v1/auth/. The implementation extracts the `data` field from the
/// standard API envelope {success, message, data, timestamp}.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class AuthRemoteDatasource {
  Future<AuthResponseModel> login(String email, String password);

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<void> logout();

  Future<AuthResponseModel> refreshToken();

  Future<UserModel> getMe();

  Future<UserModel> activateAccount(String email, String activationCode);
}

/// Dio-backed implementation of [AuthRemoteDatasource].
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v1/auth/login',
      data: LoginRequestModel(email: email, password: password).toJson(),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v1/auth/register',
      data: RegisterRequestModel(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ).toJson(),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('api/v1/auth/logout');
  }

  @override
  Future<AuthResponseModel> refreshToken() async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v1/auth/refresh-token',
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('api/v1/auth/me');
    final data = response.data!['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> activateAccount(
    String email,
    String activationCode,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v1/auth/activate-account',
      data: ActivateAccountRequestModel(
        email: email,
        activationCode: activationCode,
      ).toJson(),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
