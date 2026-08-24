import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class GetProductCategoriesUsecase
    implements UseCase<List<ProductCategory>, NoParams> {
  final ProductRepository repository;

  GetProductCategoriesUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductCategory>>> call(NoParams params) async {
    return await repository.getProductCategories();
  }
}
