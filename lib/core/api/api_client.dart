import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/*
class ApiClient {
  final Dio dio;

  ApiClient(Ref ref)
    : dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000')) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = ref.read(authTokenProvider);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/users/login',
        data: {'username': username, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Unknown error';
      throw Exception(errorMessage);
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      final response = await dio.get('/users/me');
      return response;
    } on DioException {
      rethrow;
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));
*/

class ApiClient {
  final Dio dio;
  ApiClient(Ref ref) : dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000'));
}

