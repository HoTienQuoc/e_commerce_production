import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variations_entity.dart';
import 'package:frontend_admin/features/variations/presentation/bloc/product_variant_bloc.dart';
import 'package:frontend_admin/features/variations/presentation/widgets/variations_table/stock_warning_banner.dart';
import 'package:frontend_admin/features/variations/presentation/widgets/variations_table/variation_filters.dart';
import 'package:frontend_admin/features/variations/presentation/widgets/variations_table/variation_table_header.dart';

class VariationCombinationsTable extends StatefulWidget {
  final List<ProductVariationsEntity> variations;
  final List<ProductVariantEntity> variants;
  final double basePrice;
  final Function(List<ProductVariantEntity>) onVariantsChanged;
  final String productId;
  final int currentStock;

  const VariationCombinationsTable({
    super.key,
    required this.variations,
    required this.variants,
    required this.basePrice,
    required this.onVariantsChanged,
    required this.productId,
    this.currentStock = 0,
  });

  @override
  State<VariationCombinationsTable> createState() =>
      _VariationCombinationsTableState();
}

class _VariationCombinationsTableState
    extends State<VariationCombinationsTable> {
  late List<ProductVariantEntity> _localVariants;
  bool _editingPrice = false;
  bool _editingStock = false;
  bool _editingSku = false;
  bool _editingDiscount = false;

  String? _selectedSize;
  String? _selectedColor;
  List<String> _availableSizes = [];
  List<String> _availableColors = [];

  @override
  void initState() {
    super.initState();
    _updateLocalStateFromWidget();
  }

  int get _totalLocalStock => _localVariants.fold(0, (sum, v) => sum + v.stock);

  void _updateLocalStateFromWidget() {
    _localVariants = List.from(widget.variants);
    _extractVariationOptions();
  }

  void _extractVariationOptions() {
    _availableSizes = widget.variations
        .firstWhere(
          (v) => v.name.toLowerCase() == 'size',
          orElse: () =>
              const ProductVariationsEntity(id: '', name: '', values: []),
        )
        .values;
    _availableColors = widget.variations
        .firstWhere(
          (v) => v.name.toLowerCase() == 'color',
          orElse: () =>
              const ProductVariationsEntity(id: '', name: '', values: []),
        )
        .values;
  }

  List<ProductVariantEntity> _getFilteredVariants() {
    return _localVariants.where((variant) {
      bool matchesSize =
          _selectedSize == null || variant.attributes['Size'] == _selectedSize;
      bool matchesColor =
          _selectedColor == null ||
          variant.attributes['Color'] == _selectedColor;
      return matchesSize && matchesColor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayVariants = _getFilteredVariants();
    final stockDifference = widget.currentStock - _totalLocalStock;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.cardBackground : AppTheme.textPrimary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock discepancy warning
            if (stockDifference != 0)
              StockWarningBanner(
                stockDifference: stockDifference,
                onDistributeStock: () => context.read<ProductVariantBloc>().add(
                  DistributeStockAcrossVariantsEvent(widget.currentStock),
                ),
              ),

            // Filters
            VariationFilters(
              availableSizes: _availableSizes,
              availableColors: _availableColors,
              selectedColor: _selectedColor,
              selectedSize: _selectedSize,
              onSizeChanged: (size) {
                setState(() {
                  _selectedSize = size;
                });
              },
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 16),
            VariationTableHeader(
              totalStock: _totalLocalStock,
              currentStock: widget.currentStock,
              onGenerateSkus: () {},
              onShowStockDistribution: () {},
              onShowBatchPriceUpdate: () {},
              onShowBatchDiscount: () {},
            ),
          ],
        ),
      ),
    );
  }
}
