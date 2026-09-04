import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/domain/repositories/variant_repository.dart';

class UpdateProductVariants
    implements UseCase<ProductVariantEntity, UpdateVariantParams> {
  final VariantRepository repository;

  UpdateProductVariants(this.repository);

  @override
  Future<Either<Failure, ProductVariantEntity>> call(
    UpdateVariantParams params,
  ) async {
    return await repository.updateProductVariant(
      params.variantId,
      params.variant,
      variantImage: params.variantImage,
    );
  }
}

class UpdateVariantParams {
  final String variantId;
  final ProductVariantEntity variant;
  final dynamic variantImage;

  UpdateVariantParams({
    required this.variantId,
    required this.variant,
    required this.variantImage,
  });
}
