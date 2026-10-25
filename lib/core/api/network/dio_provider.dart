
import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/token_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  if (kIsWeb) {
    dio.httpClientAdapter = BrowserHttpClientAdapter(
      withCredentials: true,
    );
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Native apps use Bearer tokens.
        // Web requests use the browser's HttpOnly cookie.
        if (!kIsWeb) {
          final token = ref.read(authTokenProvider);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
    ),
  );

  return dio;
});
