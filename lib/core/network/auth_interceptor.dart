import 'package:dio/dio.dart';
import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.secureStorage,
    required this.dio,
    required this.onSessionExpired,
  });

  final SecureTokenStorage secureStorage;
  final Dio dio;
  final void Function() onSessionExpired;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await secureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await secureStorage.getRefreshToken();
        if (refreshToken == null) {
          onSessionExpired();
          handler.reject(err);
          return;
        }

        final response = await dio.post<Map<String, dynamic>>(
          'api/v1/auth/refresh-token',
          options: Options(
            headers: {'Authorization': 'Bearer $refreshToken'},
          ),
        );

        final data = response.data?['data'] as Map<String, dynamic>?;
        final newAccessToken = data?['access_token'] as String?;
        final newRefreshToken = data?['refresh_token'] as String?;

        if (newAccessToken == null || newRefreshToken == null) {
          onSessionExpired();
          handler.reject(err);
          return;
        }

        await secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch<dynamic>(retryOptions);
        handler.resolve(retryResponse);
      } catch (_) {
        onSessionExpired();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}
