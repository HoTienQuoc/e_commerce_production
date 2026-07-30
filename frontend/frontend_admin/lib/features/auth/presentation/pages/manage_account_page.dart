import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/features/auth/domain/entities/user_entity.dart';
import 'package:frontend_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ManageAccountPage extends StatefulWidget {
  final UserEntity user;
  const ManageAccountPage({super.key, required this.user});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _usernameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant ManageAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _initController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account'),
        // backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLarge),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is ProfileUpdateSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Account updated successfully',
                          style: AppTheme.bodyMedium(),
                        ),
                        backgroundColor: AppTheme.positive,
                      ),
                    );
                    setState(() {
                      _imageChanged = false;
                    });
                  } else if (state is ProfileUpdateError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to update account',
                          style: AppTheme.bodyMedium(),
                        ),
                        backgroundColor: AppTheme.negative,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final currentUser = state is Authenticated
                      ? state.user
                      : widget.user;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
