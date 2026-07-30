import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/auth/token_manager.dart';
import 'package:frontend_admin/core/network/api_client.dart';
import 'package:frontend_admin/core/network/network_info.dart';
import 'package:frontend_admin/core/routes/dashboard_router_observer.dart';
import 'package:frontend_admin/core/services/navigation_service.dart';
import 'package:frontend_admin/core/widget/dashboard_side_bar.dart';
import 'package:frontend_admin/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:frontend_admin/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:frontend_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend_admin/features/auth/domain/usecases/auth_usecases.dart';
import 'package:frontend_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance; // sl = Service locator
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> init() async {
  // Core service that don't depend on other services
  await _initCoreServices();
  // Auth Components
  await _initAuth();
}

Future<void> _initCoreServices() async {
  // Navigator key for global navigation
  sl.registerLazySingleton<GlobalKey<NavigatorState>>(
    () => GlobalKey<NavigatorState>(),
  );
  sl.registerLazySingleton(() => NavigationController());
  sl.registerLazySingleton(() => NavigationService());
  sl.registerLazySingleton(() => DashboardRouterObserver(sl()));
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => Dio());

  sl.registerLazySingleton(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  final tokenManager = TokenManager(localDataSource: sl<AuthLocalDataSource>());
  sl.registerSingleton<TokenManager>(tokenManager);

  final apiClient = ApiClient(
    dio: Dio(),
    tokenManager: tokenManager,
    onAuthenticationFailed: () {},
  );
  sl.registerSingleton(apiClient);
}

Future<void> _initAuth() async {
  // Auth Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      getCurrentUserUsecase: sl<GetCurrentUserUsecase>(),
      loginUsecase: sl<LoginUsecase>(),
      logoutUsecase: sl<LogoutUsecase>(),
      updateProfileUsecase: sl<UpdateProfileUsecase>(),
      validateTokenUsecase: sl<ValidateTokenUsecase>(),
    ),
  );

  // Register data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      tokenManager: sl<TokenManager>(),
    ),
  );

  // Register repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      tokenManager: sl<TokenManager>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Register use cases
  sl.registerLazySingleton(() => LoginUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ValidateTokenUsecase(sl<AuthRepository>()));
}
