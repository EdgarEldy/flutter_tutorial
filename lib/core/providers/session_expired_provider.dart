import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_expired_provider.g.dart';

/// Signal set by [AuthInterceptor] when the refresh token is no longer valid.
/// [AuthNotifier] listens to this and triggers logout automatically.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
@Riverpod(keepAlive: true)
class SessionExpiredSignal extends _$SessionExpiredSignal {
  @override
  bool build() => false;

  void trigger() => state = true;
  void clear() => state = false;
}
