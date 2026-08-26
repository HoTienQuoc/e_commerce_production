import 'package:frontend_admin/features/products/data/models/paginated_product_model.dart';
import 'package:frontend_admin/features/products/data/models/product_filter_model.dart';
import 'package:frontend_admin/features/products/data/models/product_image_model.dart';
import 'package:frontend_admin/features/products/data/models/product_model.dart';

abstract class ProductRemoteDatasource {
  Future<PaginatedProductModel> getProductsPaginated(
    Map<String, dynamic> params,
  );

  Future<ProductModel> getProductById(String id);

  Future<ProductModel> createProduct(
    ProductModel product, {
    List<dynamic>? images,
  });

  Future<ProductModel> updateProduct(
    String id,
    ProductModel product, {
    List<dynamic>? newImages,
    List<String>? removedImageIds,
  });

  Future<bool> deleteProducts(String id);

  Future<bool> updateProductStock(String id, int newStock, String reason);

  Future<ProductModel> updateProductPrice(
    String id, {
    required double price,
    double? discountPrice,
  });

  Future<bool> toggleProductStatus(String id);

  Future<ProductModel> updateProductProfitMargin(
    String id, {
    required double cost,
    required double price,
    double? discountPrice,
    required double profitMargin,
  });

  Future<bool> deleteProductImage(String productId, String imageId);

  Future<bool> bulkDeleteProducts(List<String> productIds);

  Future<List<CategoryModel>> getProductCategories();

  Future<ProductFilterModel> getProductFilters();

  Future<List<ProductImageModel>> manageProductImages(
    String id, {
    required List<dynamic> images,
  });
}
