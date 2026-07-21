import 'package:frontend_admin/core/theme/theme.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Frontend Clothes Admin Login",
            style: AppTheme.headingLarge().copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Login Form')
Widget loginFormPreview() {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: const Scaffold(
      body: Center(
        child: Padding(padding: EdgeInsets.all(24), child: LoginForm()),
      ),
    ),
  );
}
