import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/features/products/domain/entities/product_entity.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_details/product_details_bloc.dart';

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
    _productDetailsBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
