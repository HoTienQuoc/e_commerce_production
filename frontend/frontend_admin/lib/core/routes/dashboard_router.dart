import 'package:flutter/material.dart';
import 'package:frontend_admin/core/routes/route_names.dart';
import 'package:frontend_admin/features/auth/presentation/pages/login_page.dart';

class DashboardRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return _buildRoute(const LoginPage(), settings);
      case RouteNames.dashboard:
        return _buildRoute(
          Center(child: Text("We are in dashboard screen")),
          settings,
        );
      default:
        return _buildRoute(Center(child: Text("No Pages")), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
