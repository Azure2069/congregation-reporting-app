import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_provider.dart';

class ServiceAssignmentsApi {
  final Dio dio;

  ServiceAssignmentsApi(this.dio);

  Future<dynamic> checkServiceAssignment(int userID, DateTime month) async {
    final response = await dio.get(
      "/service_assignment/$userID",
      queryParameters: {
        'service_month':
            '${month.year.toString().padLeft(4, '0')}-'
            '${month.month.toString().padLeft(2, '0')}-'
            '${month.day.toString().padLeft(2, '0')}',
      },
    );
    return response.data;
  }

  Future<dynamic> addServiceAssignment(
    int userId,
    String serviceType,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    final response = await dio.post(
      "/service_assignment",
      queryParameters: {'user_id': userId},
      data: {
        'service_type': serviceType,
        'start_date': _dateOnly(startDate),
        'end_date': endDate == null ? null : _dateOnly(endDate),
      },
    );
    return response.data;
  }

  Future<dynamic> updateServiceAssignment(
    int assignmentId,
    String serviceType,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    final response = await dio.put(
      '/service_assignment/$assignmentId',
      data: {
        'service_type': serviceType,
        'start_date': _dateOnly(startDate),
        'end_date': endDate == null ? null : _dateOnly(endDate),
      },
    );
    return response.data;
  }

  Future<dynamic> getAssignments() async {
    final response = await dio.get("/service_assignment");
    return response.data;
  }
}

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

final serviceAssignmentsApiProvider = Provider<ServiceAssignmentsApi>(
  (ref) => ServiceAssignmentsApi(ref.watch(dioProvider)),
);

final checkServiceAssignmentProvider =
    FutureProvider.family<dynamic, (int, DateTime)>((ref, parameters) {
      final userId = parameters.$1;
      final month = parameters.$2;

      return ref
          .watch(serviceAssignmentsApiProvider)
          .checkServiceAssignment(userId, month);
    });

final getAssignmentsProvider = FutureProvider<dynamic>(
  (ref) => ref.watch(serviceAssignmentsApiProvider).getAssignments(),
);
