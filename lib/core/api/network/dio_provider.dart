import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/token_provider.dart';
import 'dio_web_adapter_stub.dart'
    if (dart.library.js_interop) 'dio_web_adapter_web.dart'
    as web_adapter;

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = kIsWeb || defaultTargetPlatform != TargetPlatform.android
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  if (kIsWeb) {
    web_adapter.configureWebAdapter(dio);
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
