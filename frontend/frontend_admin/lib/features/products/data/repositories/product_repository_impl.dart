import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/exceptions.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/network/network_info.dart';
import 'package:frontend_admin/features/products/data/data_sources/product_remote_datasource.dart';
import 'package:frontend_admin/features/products/domain/entities/paginated_products_entity.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/domain/entities/product_filters_entity.dart';
import 'package:frontend_admin/features/products/domain/entities/product_image_entity.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  /// A private helper method to execute a repository action, handling network checks and exceptions centrally.
  Future<Either<Failure, T>> _getRepositoryAction<T>(
    Future<T> Function() action,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await action();
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException {
        return Left(NetworkFailure());
      } on CacheException {
        return Left(CacheFailure());
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> bulkDeleteProducts(List<String> productIds) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product, {
    List<dynamic>? images,
  }) async {
    return _getRepositoryAction(
      () => remoteDatasource.createProduct(
        _mapProductToModel(product),
        images: images,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> deleteProductImage(
    String productId,
    String imageId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    return await _getRepositoryAction(
      () => remoteDatasource.getProductById(id),
    );
  }

  @override
  Future<Either<Failure, List<ProductCategory>>> getProductCategories() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductFiltersEntity>> getProductFilters() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PaginatedProductsEntity>> getProductsPaginated({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    stockStatus,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    Map<String, dynamic>? extraParams,
  }) async {
    final params = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (stockStatus != null) 'stock_status': stockStatus.toString(),
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id': categoryId,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
    };
    if (extraParams != null) {
      params.addAll(
        extraParams.map((key, value) => MapEntry(key, value.toString())),
      );
    }
    return await _getRepositoryAction(() async {
      final model = await remoteDatasource.getProductsPaginated(params);
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, List<ProductImageEntity>>> manageProductImages(
    String id,
    List<dynamic> images,
    List<bool> isPrimaryList,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> toggleProductStatus(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    String id,
    ProductEntity product, {
    List<dynamic>? newImages,
    List<String>? removedImagesIds,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateProductPrice(
    String id, {
    required double price,
    double? discountPrice,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProductProfitMargin(
    String id, {
    required double cost,
    required double price,
    double? discountPrice,
    required double profitMargin,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateProductStock(
    String id,
    int newStock,
    String reason,
  ) {
    throw UnimplementedError();
  }
}
