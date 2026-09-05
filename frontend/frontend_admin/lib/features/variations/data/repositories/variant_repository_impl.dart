import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/exceptions.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/network/network_info.dart';
import 'package:frontend_admin/features/variations/data/datasources/variant_remote_datasource.dart';
import 'package:frontend_admin/features/variations/data/models/product_variant_model.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/domain/repositories/variant_repository.dart';

class VariantRepositoryImpl implements VariantRepository {
  final VariantRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  VariantRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  ProductVariantModel _convertToVariantModel(ProductVariantEntity variant) {
    return variant is ProductVariantModel
        ? variant
        : ProductVariantModel(
            id: variant.id,
            productId: variant.productId,
            attributes: variant.attributes,
            sku: variant.sku,
            price: variant.price,
            discountPrice: variant.discountPrice,
            stock: variant.stock,
            image: variant.image,
            createdAt: variant.createdAt,
            updatedAt: variant.updatedAt,
          );
  }

  void _processVariantImage(Map<String, dynamic> data, dynamic variantImage) {
    if (variantImage != null) {
      if (variantImage is File) {
        final base64Image = base64Encode(variantImage.readAsBytesSync());
        data['image_data'] = 'data:image/jpeg;base64,$base64Image';
      } else if (variantImage is String &&
          variantImage.startsWith('data:image')) {
        data['image_data'] = variantImage;
      }
    }
  }

  @override
  Future<Either<Failure, ProductVariantEntity>> createProductVariant(
    String productId,
    ProductVariantEntity variant, {
    variantImage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final variantModel = _convertToVariantModel(variant);
        final data = variantModel.toJsonForCreate();
        _processVariantImage(data, variantImage);
        final payload = {
          'variants': [data],
          'variations': {},
        };
        final response = await remoteDatasource.manageProductVariants(
          productId,
          payload,
        );
        final variants = response['variants'] as List;
        if (variants.isEmpty) {
          return Left(
            ServerFailure(message: 'Created variant not found in response'),
          );
        }
        return Right(ProductVariantModel.fromJson(variants.last));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to create product variant'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProductVariant(
    String productId,
    String variantId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final payload = {'delete_variant_id': variantId};
        await remoteDatasource.manageProductVariants(productId, payload);
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to delete product variant'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> distributeProductStock(
    String productId,
    Map<String, dynamic> variantsData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> serializedData = Map<String, dynamic>.from(
          variantsData,
        );
        serializedData['is_stock_distribution'] = true;
        await remoteDatasource.distributeProductStock(
          productId,
          serializedData,
        );
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Failed to distribute product stock:  ${e.toString()}',
          ),
        );
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductVariantEntity>>> getProductVariants(
    String productId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final variants = await remoteDatasource.getProductVariants(productId);
        return Right(variants);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to fetch product variants'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> manageProductVariants(
    String id,
    Map<String, dynamic> variantsData,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // Check if this is a stock distribution operation
        final bool isStockDistribution =
            variantsData['is_stock_distribution'] ?? false;
        if (isStockDistribution) {
          return await distributeProductStock(id, variantsData);
        }
        await remoteDatasource.manageProductVariants(id, variantsData);
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(
            message: 'Failed to manage product variants: ${e.toString()}',
          ),
        );
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ProductVariantEntity>> updateProductVariant(
    String variantId,
    ProductVariantEntity variant, {
    variantImage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final variantModel = _convertToVariantModel(variant);
        final data = variantModel.toJson();
        _processVariantImage(data, variantImage);
        data['id'] = variantId;
        final payload = {
          'variants': ['data'],
          'variations': {},
        };
        final response = await remoteDatasource.manageProductVariants(
          variant.productId,
          payload,
        );
        final variants = response['variants'] as List;
        final updatedVariant = variants.firstWhere(
          (v) => v['id'] == variantId,
          orElse: () =>
              throw Exception('Updated variant not found in response'),
        );
        return Right(ProductVariantModel.fromJson(updatedVariant));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to update product variant'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
