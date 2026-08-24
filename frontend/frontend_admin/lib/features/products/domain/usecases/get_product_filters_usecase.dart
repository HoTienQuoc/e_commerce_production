import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/entities/product_filters_entity.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class GetProductFiltersUsecase
    implements UseCase<ProductFiltersEntity, NoParams> {
  final ProductRepository repository;

  GetProductFiltersUsecase(this.repository);

  @override
  Future<Either<Failure, ProductFiltersEntity>> call(NoParams params) async {
    return await repository.getProductFilters();
  }
}
