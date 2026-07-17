import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/auth/domain/repositories/auth_repository.dart';

class ValidateToken implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  ValidateToken(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.validateToken();
  }
}
