import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/secure_token_storage.dart';

class _PendingRequest {
  const _PendingRequest(this.options, this.handler, this.err);

  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  final DioException err;
}

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
  final List<_PendingRequest> _queue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('auth/refresh-token')) {
      handler.next(options);
      return;
    }
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
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _queue.add(_PendingRequest(err.requestOptions, handler, err));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _rejectAll(err);
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
        _rejectAll(err);
        onSessionExpired();
        handler.reject(err);
        return;
      }

      await secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      await _replayAll(newAccessToken);

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      _rejectAll(err);
      onSessionExpired();
      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _replayAll(String newAccessToken) async {
    final pending = List<_PendingRequest>.of(_queue);
    _queue.clear();
    for (final item in pending) {
      item.options.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        final response = await dio.fetch<dynamic>(item.options);
        item.handler.resolve(response);
      } catch (_) {
        item.handler.reject(item.err);
      }
    }
  }

  void _rejectAll(DioException err) {
    final pending = List<_PendingRequest>.of(_queue);
    _queue.clear();
    for (final item in pending) {
      item.handler.reject(item.err);
    }
  }
}
