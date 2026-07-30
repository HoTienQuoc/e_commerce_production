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

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manage Account', style: AppTheme.headingMedium()),
                        SizedBox(height: AppTheme.spacingLarge),
                        // Profile picture section
                        Center(
                          child: Column(
                            children: [_buildProfilePicture(currentUser)],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(UserEntity user) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accentBlue.withAlpha((0.2 * 255).round()),
            border: Border.all(color: AppTheme.borderColor, width: 2),
          ),
          child: ClipOval(child: _buildProfileImageContent(user)),
        ),
      ],
    );
  }

  Widget _buildProfileImageContent(UserEntity user) {
    if (_imageChanged && _webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(user);
        },
      );
    }
    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      return Image.network(
        user.profilePictureUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(user);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppTheme.accentBlue,
            ),
          );
        },
      );
    }
    return _buildFallbackAvatar(user);
  }

  Widget _buildFallbackAvatar(UserEntity user) {
    return Center(
      child: Text(
        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
        style: AppTheme.headingLarge().copyWith(color: AppTheme.accentBlue),
      ),
    );
  }
}
