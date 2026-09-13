import 'package:flutter/material.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';

class VariationPriceCell extends StatelessWidget {
  final ProductVariantEntity variant;
  final double basePrice;
  final bool isEditing;
  final Function(double?) onChanged;

  const VariationPriceCell({
    super.key,
    required this.variant,
    required this.basePrice,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    return isEditing
        ? TextFormField(
            initialValue: variant.price.value.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              prefixText: variant.price.currency == 'USD'
                  ? '\$'
                  : variant.price.currency,
              prefixStyle: TextStyle(color: textColor),
            ),
            style: TextStyle(color: textColor),
            onChanged: (value) {
              final price = double.tryParse(value);
              onChanged(price);
            },
          )
        : Text(
            '${variant.price.currency == 'USD' ? '\$' : variant.price.currency} ${variant.price.value.toStringAsFixed(2)}',
            style: TextStyle(
              color: variant.price.value > basePrice
                  ? (isDark ? AppTheme.positive : AppTheme.positive)
                  : (variant.price.value < basePrice
                        ? (isDark ? AppTheme.negative : AppTheme.negative)
                        : textColor),
              fontWeight: FontWeight.w500,
            ),
          );
  }
}
