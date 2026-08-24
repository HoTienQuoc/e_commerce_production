import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/entities/product_image_entity.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class ManageProductImagesUsecase
    implements UseCase<List<ProductImageEntity>, ManageImagesParams> {
  final ProductRepository repository;

  ManageProductImagesUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductImageEntity>>> call(
    ManageImagesParams params,
  ) async {
    return await repository.manageProductImages(
      params.id,
      params.images,
      params.isPrimaryList,
    );
  }
}

class ManageImagesParams {
  final String id;
  final List<dynamic> images;
  final List<bool> isPrimaryList;

  ManageImagesParams({
    required this.id,
    required this.images,
    required this.isPrimaryList,
  });
}
