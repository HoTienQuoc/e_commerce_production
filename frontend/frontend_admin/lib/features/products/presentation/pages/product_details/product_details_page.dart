import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_details/product_details_bloc.dart';
import 'package:frontend_admin/features/products/presentation/pages/components/product_actions_handler.dart';
import 'package:frontend_admin/features/products/presentation/pages/product_details/components/product_details_header.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late ProductEntity _currentProduct;
  StreamSubscription<_ProductDetailsPageState>? _productSubscription;
  ProductDetailsBloc? _productDetailsBloc;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productDetailsBloc = BlocProvider.of<ProductDetailsBloc>(context);

    if (_productDetailsBloc == null) {
      // _setupBlocListener();
      _loadProductDetails();
    }
  }

  void _loadProductDetails() {
    if (_productDetailsBloc != null) {
      _productDetailsBloc!.add(GetProductByIdEvent(_currentProduct.id));
    }
  }

  // void _setupBlocListener() {
  //   if (event is Product)
  // }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _productSubscription = null;
    _productDetailsBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductDetailsBloc, ProductDetailsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!, style: AppTheme.bodyMedium()),
              backgroundColor: AppTheme.negative,
            ),
          );
        } else if (state.isOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Operation Completed Successfully.",
                style: AppTheme.bodyMedium(),
              ),
              backgroundColor: AppTheme.success,
            ),
          );
        }

        if (state.isOperationSuccess && state.product == null) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductDetailsHeader(
                  product: _currentProduct,
                  onEditPressed: _handleEditProduct,
                  onDeletePressed: onDeletePressed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleEditProduct() {
    ProductActionsHandler.navigateToEditPage(context, _currentProduct);
  }
}
