part of 'product_details_bloc.dart';

abstract class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();
  @override
  List<Object?> get props => [];
}

class GetProductByIdEvent extends ProductDetailsEvent {
  final String id;

  const GetProductByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProductEvent extends ProductDetailsEvent {
  final ProductEntity product;
  final List<dynamic>? images;

  const CreateProductEvent({required this.product, required this.images});

  @override
  List<Object?> get props => [product, images];
}

class UpdateProductEvent extends ProductDetailsEvent {
  final String id;
  final ProductEntity product;
  final List<dynamic>? newImages;

  const UpdateProductEvent({
    required this.id,
    required this.product,
    required this.newImages,
  });

  @override
  List<Object?> get props => [id, product, newImages];
}

class DeleteProductEvent extends ProductDetailsEvent {
  final String productId;

  const DeleteProductEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class ToggleProductStatusEvent extends ProductDetailsEvent {
  final String id;

  const ToggleProductStatusEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateProductStockEvent extends ProductDetailsEvent {
  final String id;
  final int newStock;
  final String? reason;

  const UpdateProductStockEvent({
    required this.id,
    required this.newStock,
    required this.reason,
  });

  @override
  List<Object?> get props => [id, newStock, reason];
}

class UpdateProductPriceEvent extends ProductDetailsEvent {
  final String id;
  final double price;
  final double? discountPrice;

  const UpdateProductPriceEvent({
    required this.id,
    required this.price,
    required this.discountPrice,
  });

  @override
  List<Object?> get props => [id, price, discountPrice];
}

class UpdateProductProfitMarginEvent extends ProductDetailsEvent {
  final String id;
  final double cost;
  final double price;
  final double? discountPrice;
  final double profitMargin;

  const UpdateProductProfitMarginEvent({
    required this.id,
    required this.cost,
    required this.price,
    required this.discountPrice,
    required this.profitMargin,
  });

  @override
  List<Object?> get props => [id, cost, price, discountPrice, profitMargin];
}

class ManageProductImagesEvent extends ProductDetailsEvent {
  final String id;
  final List<dynamic> images;
  final List<bool> isPrimaryList;

  const ManageProductImagesEvent({
    required this.id,
    required this.images,
    required this.isPrimaryList,
  });

  @override
  List<Object?> get props => [id, images, isPrimaryList];
}

class DeleteProductImageEvent extends ProductDetailsEvent {
  final String productId;
  final String imageId;

  const DeleteProductImageEvent({
    required this.productId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [productId, imageId];
}

class ClearProductDetailErrorEvent extends ProductDetailsEvent {}

class ClearProductDetailOperationSuccessEvent extends ProductDetailsEvent {}

class ResetProductDetailStateEvent extends ProductDetailsEvent {}
