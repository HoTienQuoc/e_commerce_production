import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/auth/domain/entities/auth_credentials_entity.dart';
import 'package:frontend_admin/features/auth/domain/entities/user_entity.dart';
import 'package:frontend_admin/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase implements UseCase<UserEntity, AuthCredentialsEntity> {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(AuthCredentialsEntity params) async {
    // Validate credentials
    if (!params.hasValidEmail) {
      return Left(
        ValidationFailure(message: "Please enter a valid email address"),
      );
    }

    if (!params.hasValidPassword) {
      return Left(
        ValidationFailure(message: "Password must match and not empty"),
      );
    }

    if (params.password.length < 6) {
      return Left(
        ValidationFailure(message: "Password must be at lease 6 characters"),
      );
    }

    return repository.registerWithEmailAndPassword(params);
  }
}
