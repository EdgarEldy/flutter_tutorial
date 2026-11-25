// Feature providers for the auth module.
// Wires datasources, repositories and use cases together using Riverpod.
// Each provider is a thin factory: no business logic lives here.
// The DI boundary is ProviderScope at the app root; no get_it or
// injection_container is used.
//
// Author: edgar.muhamyangabo
// Date: 2026-11-25
// Project: flutter_tutorial
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/secure_storage_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/password_reset_repository.dart';
import '../../domain/usecases/activate_account_use_case.dart';
import '../../domain/usecases/confirm_password_reset_use_case.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/is_logged_in_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/send_password_reset_otp_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/verify_password_reset_otp_use_case.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/password_reset_remote_datasource.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/password_reset_repository_impl.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      ref.watch(authRemoteDatasourceProvider),
      ref.watch(secureTokenStorageProvider),
    );

@riverpod
PasswordResetRemoteDatasource passwordResetRemoteDatasource(Ref ref) =>
    PasswordResetRemoteDatasourceImpl(ref.watch(dioProvider));

@riverpod
PasswordResetRepository passwordResetRepository(Ref ref) =>
    PasswordResetRepositoryImpl(ref.watch(passwordResetRemoteDatasourceProvider));

@riverpod
SignInUseCase signInUseCase(Ref ref) => SignInUseCase(
      ref.watch(authRepositoryProvider),
      ref.watch(secureTokenStorageProvider),
    );

@riverpod
RegisterUseCase registerUseCase(Ref ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
LogoutUseCase logoutUseCase(Ref ref) => LogoutUseCase(
      ref.watch(authRepositoryProvider),
      ref.watch(secureTokenStorageProvider),
    );

@riverpod
GetProfileUseCase getProfileUseCase(Ref ref) =>
    GetProfileUseCase(ref.watch(authRepositoryProvider));

@riverpod
ActivateAccountUseCase activateAccountUseCase(Ref ref) =>
    ActivateAccountUseCase(ref.watch(authRepositoryProvider));

@riverpod
IsLoggedInUseCase isLoggedInUseCase(Ref ref) =>
    IsLoggedInUseCase(ref.watch(authRepositoryProvider));

@riverpod
SendPasswordResetOtpUseCase sendPasswordResetOtpUseCase(Ref ref) =>
    SendPasswordResetOtpUseCase(ref.watch(passwordResetRepositoryProvider));

@riverpod
VerifyPasswordResetOtpUseCase verifyPasswordResetOtpUseCase(Ref ref) =>
    VerifyPasswordResetOtpUseCase(ref.watch(passwordResetRepositoryProvider));

@riverpod
ConfirmPasswordResetUseCase confirmPasswordResetUseCase(Ref ref) =>
    ConfirmPasswordResetUseCase(ref.watch(passwordResetRepositoryProvider));
