import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Contract for all authentication operations. Stateless: never reads
/// or writes [SecureTokenStorage] itself.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
abstract interface class AuthRepository {
  /// Authenticates the user with [email] and [password].
  Future<Either<Failure, AuthTokens>> signIn(String email, String password);

  /// Creates a new inactive user account.
  /// The account must be activated via [activateAccount] before sign-in.
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// Signs out the current user server-side.
  Future<Either<Failure, Unit>> logout();

  /// Exchanges the stored refresh token for a new access/refresh token pair.
  Future<Either<Failure, AuthTokens>> refreshToken();

  /// Returns the profile of the currently authenticated user.
  Future<Either<Failure, User>> getMe();

  /// Activates an account with a 6-digit [activationCode] sent by email.
  Future<Either<Failure, User>> activateAccount(
    String email,
    String activationCode,
  );

  /// Returns true if a valid access token is stored locally (no network call).
  Future<bool> isLoggedIn();
}
