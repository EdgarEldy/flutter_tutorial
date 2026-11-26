import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import 'secure_storage_provider.dart';
import 'session_expired_provider.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final secureStorage = ref.watch(secureTokenStorageProvider);
  final dioInstance = DioClient.create();
  dioInstance.interceptors.add(
    AuthInterceptor(
      secureStorage: secureStorage,
      dio: dioInstance,
      onSessionExpired: () =>
          ref.read(sessionExpiredSignalProvider.notifier).trigger(),
    ),
  );
  return dioInstance;
}
