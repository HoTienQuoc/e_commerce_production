import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_admin/core/usecases/usecase.dart';
import 'package:frontend_admin/features/auth/domain/entities/auth_credentials_entity.dart';
import 'package:frontend_admin/features/auth/domain/entities/user_entity.dart';
import 'package:frontend_admin/features/auth/domain/usecases/auth_usecases.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Use cases
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final ValidateTokenUsecase validateTokenUsecase;

  AuthBloc({
    required this.getCurrentUserUsecase,
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.updateProfileUsecase,
    required this.validateTokenUsecase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Validate the token
    final validateResult = await validateTokenUsecase(NoParams());
    final isTokenValid = validateResult.getOrElse(() => false);

    if (!isTokenValid) {
      emit(UnAuthenticated());
      return;
    }

    final userResult = await getCurrentUserUsecase(NoParams());
    userResult.fold(
      (failure) {
        emit(UnAuthenticated());
      },
      (user) {
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(UnAuthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final credentials = AuthCredentialsEntity(
      email: event.email,
      password: event.password,
    );

    final result = await loginUsecase(credentials);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUsecase(NoParams());

    result.fold(
      (failure) =>
          emit(AuthError(message: 'Logout failed: ${failure.message}')),
      (_) => emit(UnAuthenticated()),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ProfileUpdating());
    final result = await updateProfileUsecase(event.params);
    result.fold((failure) => emit(ProfileUpdateError(error: failure.message)), (
      updatedUser,
    ) {
      emit(ProfileUpdateSuccess(updatedUser: updatedUser));
      emit(Authenticated(user: updatedUser));
    });
  }
}
