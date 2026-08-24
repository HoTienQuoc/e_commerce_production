import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class UpdateProductProfitUsecase
    implements UseCase<ProductEntity, UpdateProfitMarginParams> {
  final ProductRepository repository;

  UpdateProductProfitUsecase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(
    UpdateProfitMarginParams params,
  ) async {
    return await repository.updateProductProfitMargin(
      params.id,
      cost: params.cost,
      price: params.price,
      discountPrice: params.discountPrice,
      profitMargin: params.profitMargin,
    );
  }
}

class UpdateProfitMarginParams {
  final String id;
  final double cost;
  final double price;
  final double? discountPrice;
  final double profitMargin;

  UpdateProfitMarginParams({
    required this.id,
    required this.cost,
    required this.price,
    required this.discountPrice,
    required this.profitMargin,
  });
}
