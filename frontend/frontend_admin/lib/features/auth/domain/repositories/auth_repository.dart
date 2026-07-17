import 'package:dartz/dartz.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/features/auth/domain/entities/auth_credentials_entity.dart';
import 'package:frontend_admin/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:frontend_admin/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  // Register a new user with email and password
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword(
    AuthCredentialsEntity credentials,
  );

  // Login with email and password
  Future<Either<Failure, UserEntity>> loginWithEmailAndPassword(
    AuthCredentialsEntity credentials,
  );

  // Refresh authentication tokens
  Future<Either<Failure, AuthTokensEntity>> refreshTokens();

  // Validate if the current tokens is still valid
  Future<Either<Failure, bool>> validateToken();

  // Get the currently authenticated user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  // Update user profile information
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    dynamic profileImage,
  });

  // Logout the current user
  Future<Either<Failure, void>> logout();
}
