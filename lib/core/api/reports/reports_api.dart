import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_provider.dart';

class ReportsApi {
  final Dio dio;

  ReportsApi(this.dio);
  Future<dynamic> addReport(
    int? hours,
    int? bibleStudies,
    bool participated,
    DateTime reportingMonth,
  ) async {
    final response = await dio.post(
      "/reports",
      data: {
        'hours': hours,
        'bible_studies': bibleStudies,
        'participated': participated,
        'reporting_month':
            '${reportingMonth.year.toString().padLeft(4, '0')}-'
            '${reportingMonth.month.toString().padLeft(2, '0')}-'
            '${reportingMonth.day.toString().padLeft(2, '0')}',
      },
    );
    return response.data;
  }

  Future<dynamic> updateStatus(int id, String status) async {
    final response = await dio.patch('/reports/$id', data: {'status': status});
    return response.data;
  }

  Future<dynamic> updateReport(
    int reportId,
    int? hours,
    int? bibleStudies,
    bool? participated,
  ) async {
    final response = await dio.put(
      '/reports/$reportId',
      data: {
        'hours': hours,
        'bible_studies': bibleStudies,
        'participated': participated,
      },
    );
    return response.data;
  }

  Future<dynamic> getGroupReports() async {
    final response = await dio.get('/reports/group/reports');
    return response.data;
  }

  Future<dynamic> getReportsById(int userId) async {
    final response = await dio.get('/reports/$userId/reports');
    return response.data;
  }
}

final reportsApiProvider = Provider<ReportsApi>((ref) {
  return ReportsApi(ref.watch(dioProvider));
});

final getGroupReportsProvider = FutureProvider<dynamic>(
  (ref) => ref.watch(reportsApiProvider).getGroupReports(),
);

final getReportsbyIdProvider = FutureProvider.family<dynamic, int>(
  (ref, userId) => ref.watch(reportsApiProvider).getReportsById(userId),
);
