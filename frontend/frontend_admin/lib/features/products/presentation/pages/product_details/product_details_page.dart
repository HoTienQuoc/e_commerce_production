import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/core/utils/responsive_helper.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_details/product_details_bloc.dart';
import 'package:frontend_admin/features/products/presentation/pages/components/product_actions_handler.dart';
import 'package:frontend_admin/features/products/presentation/pages/product_details/components/product_details_header.dart';
import 'package:frontend_admin/features/products/presentation/pages/product_details/components/product_images_section.dart';
import 'package:frontend_admin/features/products/presentation/pages/product_details/components/product_infor_section.dart';
import 'package:frontend_admin/features/products/presentation/pages/product_details/components/product_tabs_section.dart';

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
                  onDeletePressed: _handleDeleteConfirmation,
                ),
                _buildConstrainedContentContainer(context),
                ProductTabsSection(product: _currentProduct),
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

  void _handleDeleteConfirmation() {
    ProductActionsHandler.showDeleteConfirmation(context, _currentProduct);
  }

  Widget _buildConstrainedContentContainer(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double maxContentWidth = width;

    if (width >= ResponsiveHelper.largeDesktopBreakpoint) {
      maxContentWidth = width * 0.9;
      maxContentWidth = maxContentWidth > 1600 ? 1600 : maxContentWidth;
    } else if (width >= ResponsiveHelper.desktopBreakpoint) {
      maxContentWidth = width * 0.95;
    }
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        padding: ResponsiveHelper.getSafeHorizontalPadding(context),
        child: _buildResponsiveContent(context),
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context) {
    return ResponsiveHelper.buildResponsiveLayout(
      context,
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImagesSection(product: _currentProduct),
          const SizedBox(height: AppTheme.spacingMedium),
          ProductInfoSection(product: _currentProduct),
        ],
      ),
      tablet: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImagesSection(product: _currentProduct),
          const SizedBox(height: AppTheme.spacingMedium),
          ProductInfoSection(product: _currentProduct),
        ],
      ),
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: ProductImagesSection(product: _currentProduct),
          ),
          const SizedBox(width: AppTheme.spacingLarge),
          Expanded(
            flex: 6,
            child: ProductInfoSection(product: _currentProduct),
          ),
        ],
      ),
    );
  }
}
