import 'package:flutter/material.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variations_entity.dart';
import 'package:frontend_admin/features/variations/presentation/widgets/variations_table/edit_table_column_header.dart';

class VariationTableBody extends StatelessWidget {
  final List<ProductVariationsEntity> variations;
  final List<ProductVariantEntity> variants;
  final List<ProductVariantEntity> allVariants;
  final double basePrice;
  final bool editingPrice;
  final bool editingStock;
  final bool editingSku;
  final bool editingDiscount;
  final VoidCallback onToggleEditingPrice;
  final VoidCallback onToggleEditingStock;
  final VoidCallback onToggleEditingSku;
  final VoidCallback onToggleEditingDiscount;
  final Function(int, ProductVariantEntity) onUpdateVariant;

  const VariationTableBody({
    super.key,
    required this.variations,
    required this.variants,
    required this.allVariants,
    required this.basePrice,
    required this.editingPrice,
    required this.editingStock,
    required this.editingSku,
    required this.editingDiscount,
    required this.onToggleEditingPrice,
    required this.onToggleEditingStock,
    required this.onToggleEditingSku,
    required this.onToggleEditingDiscount,
    required this.onUpdateVariant,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tableHeaderColor = isDark
        ? Colors.grey.shade800
        : AppTheme.primaryLight.withAlpha((0.1 * 255).round());
    final tableRowColor1 = isDark ? AppTheme.cardBackground : Colors.white;
    final tableRowColor2 = isDark
        ? AppTheme.backgroundMedium
        : Colors.grey.shade50;
    final borderColor = isDark ? AppTheme.borderColor : Colors.grey.shade300;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            ...variations.map(
              (variation) => DataColumn(
                label: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppTheme.spacingSmall,
                  ),
                  child: Text(
                    variation.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            DataColumn(
              label: EditTableColumnHeader(
                title: 'Price',
                isEditing: editingPrice,
                onToggle: onToggleEditingPrice,
                isDark: isDark,
              ),
            ),
            DataColumn(
              label: EditTableColumnHeader(
                title: 'Stock',
                isEditing: editingStock,
                onToggle: onToggleEditingStock,
                isDark: isDark,
              ),
            ),
            DataColumn(
              label: EditTableColumnHeader(
                title: 'SKU',
                isEditing: editingSku,
                onToggle: onToggleEditingSku,
                isDark: isDark,
              ),
            ),
            DataColumn(
              label: EditTableColumnHeader(
                title: 'Discount',
                isEditing: editingDiscount,
                onToggle: onToggleEditingDiscount,
                isDark: isDark,
              ),
            ),
          ],
          rows: variants.asMap().entries.map((entry) {
            final index = allVariants.indexOf(entry.value);
            final variant = entry.value;
            final isEven = entry.key % 2 == 0;
            return DataRow(
              cells: [
                ...variations.map(
                  (variation) => DataCell(
                    Text(
                      variant.attributes[variation.name] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                DataCell(VariationPriceCell),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
