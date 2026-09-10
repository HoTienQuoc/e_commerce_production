import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/presentation/bloc/product_variant_bloc.dart';

class ProductVariationsManager extends StatefulWidget {
  final String productId;
  final Map<String, List<String>> initialVariations;
  final List<ProductVariantEntity>? initialVariants;
  final List<String> initialSizes;
  final double basePrice;
  final int currentStock;
  final Function(Map<String, List<String>>, List<ProductVariantEntity>)?
  onVariationsChanges;

  const ProductVariationsManager({
    super.key,
    required this.productId,
    this.initialVariations = const {},
    this.initialVariants,
    this.initialSizes = const [],
    required this.basePrice,
    this.currentStock = 0,
    this.onVariationsChanges,
  });

  @override
  State<ProductVariationsManager> createState() =>
      _ProductVariationsManagerState();
}

class _ProductVariationsManagerState extends State<ProductVariationsManager> {
  bool _showCombinations = true;
  final bool _showSizesSection = true;

  @override
  void initState() {
    super.initState();
    // Initialize the BLoC with all necessary data
    context.read<ProductVariantBloc>().add(
      InitializeVariationsDataEvent(
        productId: widget.productId,
        initialVariations: widget.initialVariations,
        initialSizes: widget.initialSizes,
        basePrice: widget.basePrice,
        currentStock: widget.currentStock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductVariantBloc, ProductVariantState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppTheme.negative,
            ),
          );
        }
        if (state.isOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Operation successful'),
              backgroundColor: AppTheme.positive,
            ),
          );
        }
      },
      builder: (context, state) {
        final variations = state.variations;
        final variants = state.variants ?? [];
        final totalStockFromVariants = variants.fold(
          0,
          (sum, v) => sum + v.stock,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.inventory, color: AppTheme.accentIvory),
                    const SizedBox(width: 8),
                    Text(
                      'Product Stock (Overall): ${widget.currentStock}',
                      style: AppTheme.bodyLarge().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
