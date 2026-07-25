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
          SizedBox(height: AppTheme.spacingLarge),

          Text(
            "Please fill in your unique admin login details below",
            style: AppTheme.bodyMedium().copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingLarge * 1.5),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email address",
                style: AppTheme.bodyMedium().copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.bodyMedium().copyWith(
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefix: Icon(
                    Icons.email_outlined,
                    color: AppTheme.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),
            ],
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
