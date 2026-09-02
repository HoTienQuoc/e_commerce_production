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
import 'package:frontend_admin/features/category/data/datasources/categories_remote_datasource.dart';
import 'package:frontend_admin/features/category/data/repositories/category_repository_impl.dart';
import 'package:frontend_admin/features/category/domain/repositories/category_repository.dart';
import 'package:frontend_admin/features/category/domain/usecases/create_categories.dart';
import 'package:frontend_admin/features/category/domain/usecases/delete_categories.dart';
import 'package:frontend_admin/features/category/domain/usecases/get_categories.dart';
import 'package:frontend_admin/features/category/domain/usecases/update_categories.dart';
import 'package:frontend_admin/features/category/presentation/bloc/category_bloc.dart';
import 'package:frontend_admin/features/products/data/data_sources/product_remote_datasource.dart';
import 'package:frontend_admin/features/products/data/repositories/product_repository_impl.dart';
import 'package:frontend_admin/features/products/domain/repositories/product_repository.dart';
import 'package:frontend_admin/features/products/domain/usecases/bulk_delete_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/create_product_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/delete_product_image_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/get_product_categories_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/get_product_filters_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/get_products_paginated_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/manage_product_images_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/toggle_product_status_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/update_product_price_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/update_product_profit_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/update_product_stock_usecase.dart';
import 'package:frontend_admin/features/products/domain/usecases/update_product_usecase.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_details/product_details_bloc.dart';
import 'package:frontend_admin/features/products/presentation/bloc/product_list/product_list_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance; // sl = Service locator
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> init() async {
  // Core service that don't depend on other services
  await _initCoreServices();
  // Auth Components
  await _initAuth();
  // Product components
  _initProductFeature();
  // Category feature
  _initCategories();
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

void _initProductFeature() {
  // Use cases
  sl.registerLazySingleton(() => GetProductByIdUsecase(sl()));
  sl.registerLazySingleton(() => CreateProductUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductUsecase(sl()));
  sl.registerLazySingleton(() => DeleteProductUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductStockUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductPriceUsecase(sl()));
  sl.registerLazySingleton(() => ToggleProductStatusUsecase(sl()));
  sl.registerLazySingleton(() => DeleteProductImageUsecase(sl()));
  sl.registerLazySingleton(() => BulkDeleteUsecase(sl()));
  sl.registerLazySingleton(() => GetProductCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetProductFiltersUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductProfitMarginUsecase(sl()));
  sl.registerLazySingleton(() => GetProductsPaginatedUsecase(sl()));
  sl.registerLazySingleton(() => ManageProductImagesUsecase(sl()));

  // bloc
  sl.registerFactory(
    () => ProductDetailsBloc(
      getProductById: sl(),
      createProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
      updateProductStock: sl(),
      updateProductPrice: sl(),
      updateProductProfitMargin: sl(),
      deleteProductImage: sl(),
      manageProductImages: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductsListBloc(
      getProductsPaginated: sl(),
      bulkDeleteProducts: sl(),

      getProductCategories: sl(),
      getProductFilters: sl(),
      toggleProductStatus: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDatasource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );
}

void _initCategories() {
  // Data sources
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));

  // Bloc
  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl(),
      createCategory: sl(),
      deleteCategory: sl(),
      updateCategory: sl(),
    ),
  );
}
