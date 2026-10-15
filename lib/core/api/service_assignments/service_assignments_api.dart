import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_provider.dart';

class ServiceAssignmentsApi {
  final Dio dio;

  ServiceAssignmentsApi(this.dio);

  Future<dynamic> checkServiceAssignment(int userID, DateTime month) async {
    final response = await dio.get(
      "/service_assignment/$userID",
      queryParameters: {'service_month':
          '${month.year.toString().padLeft(4, '0')}-'
          '${month.month.toString().padLeft(2, '0')}-'
          '${month.day.toString().padLeft(2, '0')}',},
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
        'start_date':
            '${startDate.year.toString().padLeft(4, '0')}-'
            '${startDate.month.toString().padLeft(2, '0')}-'
            '${startDate.day.toString().padLeft(2, '0')}',
        'end_date':
            '${endDate?.year.toString().padLeft(4, '0')}-'
            '${endDate?.month.toString().padLeft(2, '0')}-'
            '${endDate?.day.toString().padLeft(2, '0')}',
      },
    );
    return response.data;
  }

  Future<dynamic> getAssignments() async {
    final response = await dio.get("/service_assignment");
    return response.data;
  }
}

final serviceAssignmentsApiProvider = Provider<ServiceAssignmentsApi>(
  (ref) => ServiceAssignmentsApi(ref.watch(dioProvider)),
);

final checkServiceAssignmentProvider = FutureProvider.family<dynamic, (int, DateTime)>(
  (ref, parameters) {
    final userId = parameters.$1;
    final month = parameters.$2;

    return ref
        .watch(serviceAssignmentsApiProvider)
        .checkServiceAssignment(userId, month);
  },
);
