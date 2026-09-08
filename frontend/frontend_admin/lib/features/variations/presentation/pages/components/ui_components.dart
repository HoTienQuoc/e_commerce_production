import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/variations/presentation/bloc/product_variant_bloc.dart';

class VariationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasChanges;
  final VoidCallback onSave;
  final VoidCallback onShowHelp;
  final VoidCallback onBack;
  const VariationsAppBar({
    super.key,
    required this.hasChanges,
    required this.onSave,
    required this.onShowHelp,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Product Variations',
        style: AppTheme.headingMedium().copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
      ),
      backgroundColor: AppTheme.primaryMedium,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.borderRadiusMedium),
          bottomRight: Radius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      actions: [
        if (hasChanges)
          BlocBuilder<ProductVariantBloc, ProductVariantState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
                child: IconButton(
                  onPressed: state.isOperationLoading ? null : onSave,
                  tooltip: 'Save Changes',
                  icon: state.isOperationLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.textPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                          color: AppTheme.textPrimary,
                        ),
                ),
              );
            },
          ),
        IconButton(
          onPressed: onShowHelp,
          icon: const Icon(Icons.help_outline, color: AppTheme.textPrimary),
          tooltip: 'Help',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
