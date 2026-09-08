import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/presentation/bloc/product_variant_bloc.dart';

class ProductVariationsScreen extends StatefulWidget {
  final String productId;
  final Map<String, List<String>> initialVariations;
  final List<ProductVariantEntity>? initialVariants;
  final List<String> initialSizes;
  final double basePrice;
  final int currentStock;

  const ProductVariationsScreen({
    super.key,
    required this.productId,
    required this.initialVariations,
    this.initialVariants,
    this.initialSizes = const [],
    required this.basePrice,
    required this.currentStock,
  });

  @override
  State<ProductVariationsScreen> createState() =>
      _ProductVariationsScreenState();
}

class _ProductVariationsScreenState extends State<ProductVariationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ProductVariantBloc>().add(
      InitializeVariationsDataEvent(
        productId: widget.productId,
        initialVariations: widget.initialVariations,
        initialSizes: widget.initialSizes,
        basePrice: widget.basePrice,
        currentStock: widget.currentStock,
      ),
    );
    _animationController = AnimationController(
      duration: const Duration(microseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool isSavingDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
