import 'package:flutter/foundation.dart';
import 'package:frontend_admin/features/auth/data/models/auth_tokens_model.dart';
import 'package:frontend_admin/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String? phoneNumber,
    String? fullName,
  );

  Future<Map<String, dynamic>> login(String email, String password);

  Future<UserModel> getUserProfile();

  Future<UserModel> updateUserProfile(
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Uint8List? profileImageBytes,
  );

  Future<AuthTokensModel> refreshTokens();

  Future<bool> validateToken();

  Future<void> logout();
}

class AutoRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> getUserProfile() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokensModel> refreshTokens() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String? phoneNumber,
    String? fullName,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateUserProfile(
    String? firstName,
    String? lastName,
    String? phoneNumber,
    Uint8List? profileImageBytes,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<bool> validateToken() {
    throw UnimplementedError();
  }
}
