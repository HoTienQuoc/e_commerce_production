import 'package:equatable/equatable.dart';
import 'package:frontend_admin/features/products/domain/entities/money_entity.dart';
import 'package:frontend_admin/features/products/domain/entities/product_image_entity.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variations_entity.dart';

class ProductVariantEntity extends Equatable {
  final String id;
  final String productId;
  final Map<String, String> attributes;
  final String? sku;
  final MoneyEntity price;
  final MoneyEntity? discountPrice;
  final int stock;
  final ProductImageEntity? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPartOfDistribution;

  const ProductVariantEntity({
    required this.id,
    required this.productId,
    required this.attributes,
    this.sku,
    required this.price,
    this.discountPrice,
    required this.stock,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.isPartOfDistribution = false,
  });

  MoneyEntity get displayPrice => discountPrice ?? price;
  bool get isOnSale =>
      discountPrice != null && discountPrice!.value < price.value;
  bool get isOutStock => stock <= 0;

  @override
  List<Object?> get props => [
    id,
    productId,
    attributes,
    sku,
    price,
    discountPrice,
    stock,
    image,
    createdAt,
    updatedAt,
    isPartOfDistribution,
  ];

  ProductVariantEntity copyWith({
    String? id,
    String? productId,
    Map<String, String>? attributes,
    String? sku,
    MoneyEntity? price,
    MoneyEntity? discountPrice,
    int? stock,
    ProductImageEntity? image,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPartOfDistribution,
  }) {
    return ProductVariantEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      attributes: attributes ?? this.attributes,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPartOfDistribution: isPartOfDistribution ?? this.isPartOfDistribution,
    );
  }
}
