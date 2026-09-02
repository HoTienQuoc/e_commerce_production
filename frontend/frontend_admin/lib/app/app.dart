import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/di/injection_container.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/core/widget/dashboard_shell.dart';
import 'package:frontend_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend_admin/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_admin/features/category/presentation/bloc/category_bloc.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_details/product_details_bloc.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_list/product_list_bloc.dart';

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider<ProductsListBloc>(
          create: (context) => sl<ProductsListBloc>(),
        ),
        BlocProvider<ProductDetailsBloc>(
          create: (context) => sl<ProductDetailsBloc>(),
        ),
        BlocProvider<CategoryBloc>(create: (context) => sl<CategoryBloc>()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Admin Dashboard",
            theme: AppTheme.buildThemeData(),
            home: _buildHome(state),
            key: ValueKey(state.runtimeType.toString()),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthState state) {
    if (state is Authenticated) {
      return const DashboardShell();
    }

    if (state is UnAuthenticated || state is AuthError) {
      return LoginPage();
    }

    // For AuthInitial, AuthLoading, etc..., show a loading indicator
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingMedium),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
