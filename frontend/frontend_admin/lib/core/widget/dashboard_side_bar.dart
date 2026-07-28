import 'package:flutter/material.dart';
import 'package:frontend_admin/core/di/injection_container.dart';
import 'package:frontend_admin/core/services/navigation_service.dart';
import 'package:frontend_admin/core/theme/theme.dart';

class NavigationController extends ValueNotifier<String> {
  static final NavigationController _instance =
      NavigationController._internal();
  factory NavigationController() => _instance;
  NavigationController._internal() : super('/dashboard');
  void setCurrentRoute(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (value != route) {
        value = route;
      }
    });
  }
}

class DashboardSideBar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  const DashboardSideBar({super.key, this.isExpanded = true, this.onToggle});

  @override
  State<DashboardSideBar> createState() => _DashboardSideBarState();
}

class _DashboardSideBarState extends State<DashboardSideBar>
    with SingleTickerProviderStateMixin {
  final NavigationController _controller = sl<NavigationController>();
  final NavigationService _navigationService = sl<NavigationService>();

  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  static const double _collapseWith = 90.0;
  static const double _expandedWith = 200.0;
  static const double _textFadeThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _widthAnimation = Tween<double>(begin: _collapseWith, end: _expandedWith)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
    _animationController.value = widget.isExpanded ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(covariant DashboardSideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _controller,
      builder: (context, currentRoute, _) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final currentWidth = _widthAnimation.value;
            final showText = _animationController.value > _textFadeThreshold;

            return Container(
              width: currentWidth,
              color: AppTheme.cardBackground,
              child: Column(children: []),
            );
          },
        );
      },
    );
  }
}
