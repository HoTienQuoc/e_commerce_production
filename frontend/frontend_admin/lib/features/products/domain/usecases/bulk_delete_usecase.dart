import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class BulkDeleteUsecase implements UseCase<bool, List<String>> {
  final ProductRepository repository;

  BulkDeleteUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(List<String> productIds) async {
    return await repository.bulkDeleteProducts(productIds);
  }
}
