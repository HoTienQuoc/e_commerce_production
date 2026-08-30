import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/features/products/domain/entities/money_entity.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/domain/usecases/product_usecase.dart';

part 'product_details_event.dart';
part 'product_details_state.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final GetProductByIdUsecase getProductById;
  final CreateProductUsecase createProduct;
  final UpdateProductUsecase updateProduct;
  final DeleteProductUsecase deleteProduct;
  final UpdateProductPriceUsecase updateProductPrice;
  final UpdateProductStockUsecase updateProductStock;
  final UpdateProductProfitMarginUsecase updateProductProfitMargin;
  final ManageProductImagesUsecase manageProductImages;
  final DeleteProductImageUsecase deleteProductImage;

  ProductDetailsBloc({
    required this.getProductById,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.updateProductPrice,
    required this.updateProductStock,
    required this.updateProductProfitMargin,
    required this.manageProductImages,
    required this.deleteProductImage,
  }) : super(ProductDetailInitial()) {
    on<GetProductByIdEvent>(_onGetProductById);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateProductStockEvent>(_onUpdateProductStock);
    on<UpdateProductPriceEvent>(_onUpdateProductPrice);
    on<UpdateProductProfitMarginEvent>(_onUpdateProductProfitMargin);
    on<ManageProductImagesEvent>(_onManageProductImages);
    on<DeleteProductImageEvent>(_onDeleteProductImage);
    on<ClearProductDetailErrorEvent>(_onClearProductError);
    on<ClearProductDetailOperationSuccessEvent>(_onClearOperationSuccess);
    on<ResetProductDetailStateEvent>(_onResetProductDetailState);
  }

  Future<void> _onGetProductById(
    GetProductByIdEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await getProductById(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
        ),
      ),
      (product) => emit(state.copyWith(product: product, isLoading: false)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await createProduct(
      CreateProductParams(product: event.product, images: event.images),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (product) => emit(
        state.copyWith(
          product: product,
          isOperationLoading: false,
          isOperationSuccess: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter emit) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );
    try {
      final result = await updateProduct(
        UpdateProductParams(
          id: event.id,
          product: event.product,
          newImages: event.newImages,
        ),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            errorMessage: _mapFailureToMessage(failure),
            isOperationLoading: false,
          ),
        ),
        (product) {
          emit(
            state.copyWith(
              product: product,
              isOperationSuccess: true,
              isOperationLoading: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: "Unexpected error: $e",
          isOperationLoading: false,
        ),
      );
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await deleteProduct(event.productId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (success) => emit(
        state.copyWith(
          product: null,
          isOperationLoading: false,
          isOperationSuccess: true,
          isDeleted: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateProductStock(
    UpdateProductStockEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await updateProductStock(
      UpdateStockParams(
        id: event.id,
        newStock: event.newStock,
        reason: event.reason ?? 'Stock update',
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (success) {
        if (state.product?.id == event.id) {
          final updatedProduct = state.product!.copyWith(stock: event.newStock);
          emit(
            state.copyWith(
              product: updatedProduct,
              isOperationLoading: false,
              isOperationSuccess: true,
            ),
          );
        } else {
          emit(
            state.copyWith(isOperationLoading: false, isOperationSuccess: true),
          );
        }
      },
    );
  }

  Future<void> _onUpdateProductPrice(
    UpdateProductPriceEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await updateProductPrice(
      UpdatePriceParams(
        id: event.id,
        price: event.price,
        discountPrice: event.discountPrice,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (success) {
        if (state.product?.id == event.id) {
          final updatedProduct = state.product!.copyWith(
            price: MoneyEntity(value: event.price),
            discountPrice: event.discountPrice != null
                ? MoneyEntity(value: event.discountPrice!)
                : state.product!.discountPrice,
          );
          emit(
            state.copyWith(
              product: updatedProduct,
              isOperationLoading: false,
              isLoading: true,
            ),
          );
        } else {
          emit(
            state.copyWith(isOperationLoading: false, isOperationSuccess: true),
          );
        }
      },
    );
  }

  Future<void> _onUpdateProductProfitMargin(
    UpdateProductProfitMarginEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await updateProductProfitMargin(
      UpdateProductProfitMarginParams(
        id: event.id,
        cost: event.cost,
        price: event.price,
        profitMargin: event.profitMargin,
        discountPrice: event.discountPrice,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (updatedProduct) {
        emit(
          state.copyWith(
            product: updatedProduct,
            isOperationLoading: false,
            isOperationSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onManageProductImages(
    ManageProductImagesEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await manageProductImages(
      ManageImagesParams(
        id: event.id,
        images: event.images,
        isPrimaryList: event.isPrimaryList,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (images) {
        if (state.product?.id == event.id) {
          final updatedProduct = state.product!.copyWith(images: images);
          emit(
            state.copyWith(
              product: updatedProduct,
              isOperationLoading: false,
              isOperationSuccess: true,
            ),
          );
        } else {
          emit(
            state.copyWith(isOperationLoading: false, isOperationSuccess: true),
          );
        }
      },
    );
  }

  Future<void> _onDeleteProductImage(
    DeleteProductImageEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        clearError: true,
        clearOperationSuccess: true,
      ),
    );

    final result = await deleteProductImage(
      DeleteImageParams(productId: event.productId, imageId: event.imageId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isOperationLoading: false,
        ),
      ),
      (success) => emit(
        state.copyWith(isOperationLoading: false, isOperationSuccess: true),
      ),
    );
  }

  void _onClearProductError(
    ClearProductDetailErrorEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearOperationSuccess(
    ClearProductDetailOperationSuccessEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state.isOperationSuccess) {
      emit(state.copyWith(clearOperationSuccess: true));
    }
  }

  void _onResetProductDetailState(
    ResetProductDetailStateEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    emit(ProductDetailsState());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server failure occurred';
      case CacheFailure _:
        return 'Cache failure occurred';
      case NetworkFailure _:
        return 'Network failure occurred. Please check your connection.';
      case ValidationFailure _:
        return 'Validation failure: ${(failure as ValidationFailure).message}';
      default:
        return 'Unexpected error occurred';
    }
  }
}
