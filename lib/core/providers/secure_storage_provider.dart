import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/secure_token_storage.dart';

part 'secure_storage_provider.g.dart';

@Riverpod(keepAlive: true)
SecureTokenStorage secureTokenStorage(Ref ref) =>
    const SecureTokenStorage(FlutterSecureStorage());
