import 'package:dio/dio.dart';
import 'package:frontend_admin/core/constants/api_endpoints.dart';
import 'package:frontend_admin/core/errors/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required this._dio}) {
    // set base options
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  // Generic request handler
  Future<dynamic> _request(Future<Response> Function() requestMaker) async {
    try {
      final response = await requestMaker();
      return response.data;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          e.message;
      throw ServerException(message: errorMessage.toString());
    } catch (e) {
      throw ServerException(
        message: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParamters,
    Options? options,
  }) {
    return _request(() => _dio.get(path, queryParameters: queryParamters));
  }

  Future<dynamic> post(String path, {dynamic data, Options? options}) {
    return _request(() => _dio.post(path, data: data));
  }

  Future<dynamic> put(String path, {dynamic data, Options? options}) {
    return _request(() => _dio.put(path, data: data));
  }

  Future<dynamic> patch(String path, {dynamic data, Options? options}) {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<dynamic> delete(String path, {dynamic data, Options? options}) {
    return _request(() => _dio.delete(path, data: data));
  }
}
