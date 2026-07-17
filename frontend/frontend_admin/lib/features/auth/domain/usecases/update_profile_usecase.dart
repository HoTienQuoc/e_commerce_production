import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend_admin/core/errors/failure.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/auth/domain/entities/user_entity.dart';
import 'package:frontend_admin/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUsecase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateUserProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      profileImage: params.profileImage,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final dynamic profileImage;

  const UpdateProfileParams(
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImage,
  );

  @override
  List<Object?> get props => [firstName, lastName, phoneNumber, profileImage];
}
