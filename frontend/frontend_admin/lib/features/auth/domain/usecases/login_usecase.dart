import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/auth/domain/entities/auth_credentials_entity.dart';
import 'package:frontend_admin/features/auth/domain/entities/user_entity.dart';
import 'package:frontend_admin/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase implements UseCase<UserEntity, AuthCredentialsEntity> {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(AuthCredentialsEntity params) async {
    // Validate credentials
    if (!params.hasValidEmail) {
      return Left(
        ValidationFailure(message: "Please enter a valid email address"),
      );
    }

    if (params.password.isEmpty) {
      return Left(
        ValidationFailure(message: "Password must be at lease 6 characters"),
      );
    }
    return repository.loginWithEmailAndPassword(params);
  }
}
