import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/products/domain/entities/paginated_products_entity.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';

class GetProductsPaginatedUsecase
    implements UseCase<PaginatedProductsEntity, ProductsFiltersParams> {
  final ProductRepository repository;

  GetProductsPaginatedUsecase(this.repository);

  @override
  Future<Either<Failure, PaginatedProductsEntity>> call(
    ProductsFiltersParams params,
  ) async {
    return await repository.getProductsPaginated(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      status: params.status,
      stockStatus: params.stockStatus,
      categoryId: params.categoryId,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      extraParams: params.extraParams,
    );
  }
}

class ProductsFiltersParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? status;
  final StockStatus? stockStatus;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final Map<String, dynamic>? extraParams;

  ProductsFiltersParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.status,
    this.stockStatus,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.extraParams,
  });
}
