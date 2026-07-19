import 'dart:convert';

import 'package:frontend_admin/core/errors/exceptions.dart';
import 'package:frontend_admin/features/auth/data/models/auth_tokens_model.dart';
import 'package:frontend_admin/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define constants for storage keys
const CACHED_TOKENS_KEY = 'CACHED_TOKENS';
const CACHED_USER_KEY = 'CACHED_USER';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(AuthTokensModel tokens);
  Future<AuthTokensModel> getTokens();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAuthData();
  Future<bool> hasTokens();
}

class AuthLocalDataSourceImple implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImple({required this.sharedPreferences});

  @override
  Future<void> cacheToken(AuthTokensModel tokens) async {
    final jsonString = json.encode(tokens.toJson());
    await sharedPreferences.setString(CACHED_TOKENS_KEY, jsonString);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await sharedPreferences.setString(CACHED_USER_KEY, jsonString);
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_KEY);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    } else {
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(CACHED_TOKENS_KEY);
    await sharedPreferences.remove(CACHED_USER_KEY);
  }

  @override
  Future<AuthTokensModel> getTokens() async {
    final jsonString = sharedPreferences.getString(CACHED_TOKENS_KEY);
    if (jsonString != null) {
      return AuthTokensModel.fromStorage(json.decode(jsonString));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<bool> hasTokens() async {
    final jsonString = sharedPreferences.getString(CACHED_TOKENS_KEY);
    if (jsonString == null) {
      return false;
    }
    try {
      final tokens = AuthTokensModel.fromStorage(json.decode(jsonString));
      return tokens.accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
