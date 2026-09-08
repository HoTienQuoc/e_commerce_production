import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/variations/domain/entities/product_variant_entity.dart';
import 'package:frontend_admin/features/variations/presentation/bloc/product_variant_bloc.dart';
import 'package:frontend_admin/features/variations/presentation/pages/components/ui_components.dart';

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
      duration: const Duration(milliseconds: 600),
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

  Future<bool> _confirmDiscard() async {
    if (!context.read<ProductVariantBloc>().state.isDirty) return true;
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Changes?', style: AppTheme.headingMedium()),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: AppTheme.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.negative),
            child: const Text('DISCARD', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  bool isSavingDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    final blocState = context.watch<ProductVariantBloc>().state;
    final bool hasChanges = blocState.isDirty;
    final bool isLoading = blocState.isOperationLoading;
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: VariationsAppBar(
          hasChanges: hasChanges,
          onSave: () {},
          onShowHelp: () {},
          onBack: () {},
        ),
      ),
    );
  }
}
