import 'package:flutter/material.dart';

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
  final NavigationController _controller;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
