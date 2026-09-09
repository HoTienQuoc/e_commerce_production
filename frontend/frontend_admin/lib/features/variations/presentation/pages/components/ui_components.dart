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

// Header section with gradient background
class VariationsHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  const VariationsHeader({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight.withAlpha((0.9 * 255).round()),
            AppTheme.primaryLight.withAlpha((0.9 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withAlpha((0.3 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure product variations',
                    style: AppTheme.headingMedium().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    'Create and manage options like size, color, and material',
                    style: AppTheme.bodyMedium().copyWith(
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              color: Colors.white,
              tooltip: 'Refresh variants',
            ),
          ],
        ),
      ),
    );
  }
}
