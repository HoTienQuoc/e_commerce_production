import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class ToggleProductStatusUsecase implements UseCase<bool, String> {
  final ProductRepository repository;

  ToggleProductStatusUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String id) async {
    return await repository.toggleProductStatus(id);
  }
}
