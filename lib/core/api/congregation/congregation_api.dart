import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../network/dio_provider.dart';

class CongregationApi {
  final Dio dio;
  CongregationApi(this.dio);
  Future<dynamic> getMyCongregation() async {
    final response = await dio.get("/congregations/");
    return response.data;
  }

  Future<dynamic> changeCongregation(int userId) async {
    final response = await dio.patch(
      "/congregations/change_congregation",
      queryParameters: {'user_id': userId},
    );
    return response.data;
  }

  Future<dynamic> createCongregation(
    String name,
    DateTime? establishedDate,
    String? circuit,
  ) async {
    final response = await dio.post(
      '/congregations',
      data: {
        'name': name,
        'established_date': establishedDate == null
    ? null
    : '${establishedDate.year.toString().padLeft(4, '0')}-'
        '${establishedDate.month.toString().padLeft(2, '0')}-'
        '${establishedDate.day.toString().padLeft(2, '0')}',
        'circuit': circuit,
      },
    );
    return response.data;
  }
}

final congregationApiProvider = Provider<CongregationApi>((ref) {
  return CongregationApi(ref.watch(dioProvider));
});

final getMyCongregationProvider = FutureProvider<dynamic>(
  (ref) => ref.read(congregationApiProvider).getMyCongregation(),
);
