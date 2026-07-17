import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:frontend_admin/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokensUsecase implements UseCase<AuthTokensEntity, NoParams> {
  final AuthRepository repository;

  RefreshTokensUsecase(this.repository);

  @override
  Future<Either<Failure, AuthTokensEntity>> call(NoParams params) {
    return repository.refreshTokens();
  }
}
