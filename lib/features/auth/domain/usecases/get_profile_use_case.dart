import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Fetches the profile of the currently authenticated user from the backend.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call() => _repository.getMe();
}
