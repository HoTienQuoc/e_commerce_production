import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend_admin/features/auth/presentation/pages/login_page.dart';

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: authBloc)],
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
      return const Center(child: Text("You are logged in"));
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
