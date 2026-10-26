import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

void configureWebAdapter(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
