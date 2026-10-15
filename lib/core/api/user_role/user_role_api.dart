import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_provider.dart';

class UserRole {
  final Dio dio;

  UserRole(this.dio);

  Future<dynamic> addRole(int userId, String role) async {
    final response = await dio.post(
      "/user_role",
      data: {'user_id': userId, 'role': role},
    );
    return response.data;
  }

  Future<dynamic> getUserRoles() async {
    final response = await dio.get('/user_role');
    return response.data;
  }
}

final userRoleApiProvider = Provider<UserRole>(
  (ref) => UserRole(ref.watch(dioProvider)),
);

final getUserRolesProvider = FutureProvider<dynamic>(
  (ref) => ref.watch(userRoleApiProvider).getUserRoles(),
);
