import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_admin/core/constants/api_endpoints.dart';
import 'package:frontend_admin/core/errors/exceptions.dart';
import 'package:frontend_admin/core/network/api_client.dart';
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
  final ApiClient apiClient;

  AutoRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getUserProfile() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final responseData = await apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (responseData['success'] != true) {
        throw ServerException(message: responseData['error'] ?? 'Login Failed');
      }

      final data = responseData['data'];
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw ServerException(message: errorMessage);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
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

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond. Please try again later.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Connection error. Please check your internet connection.';
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      // Handle specific error responses
      if (data is Map && data.containsKey('error')) {
        final errorMessage = data['error'].toString();
        // check for specific error patterns
        if (errorMessage.contains('locked')) {
          return "Your account has been temporarily locked due to multiple failed login attempts. Please try again later.";
        } else if (errorMessage.contains('Invalid email or password')) {
          return 'The email or password you entered is incorrect. Please try again.';
        } else if (errorMessage.contains('disable')) {
          return 'Your account has been disabled. Please contact support for assistance.';
        }
        return errorMessage;
      } else if (statusCode == 401) {
        return "Invalid email or password. Please check credentials and try again.";
      } else if (statusCode == 403) {
        if (data is Map &&
            data.containsKey('lockout') &&
            data['lockout'] == true) {
          return "Account temporarily locked due to multiple failed attempts. Try again later.";
        }
        return "Access denied. Please contact support if this problem persists";
      } else if (statusCode == 404) {
        return "Services not found. Please check your connection and try again.";
      } else if (statusCode == 400) {
        return "Invalid request. Please check your inputs and try again.";
      } else if (statusCode == 500) {
        return "Server error. Please try again later or contact support.";
      } else {
        return "Server error ($statusCode). Please try again later.";
      }
    }
    return "Network error. Please check your connection and try again.";
  }
}
