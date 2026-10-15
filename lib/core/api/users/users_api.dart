import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_provider.dart';

class UsersApi {
  final Dio dio;
  UsersApi(this.dio);

  Future<dynamic> login(String username, String password) async {
    
      final response = await dio.post(
        '/users/login',
        data: {'username': username, 'password': password},
      );
      return response.data;
    
  }

  Future<dynamic> getCurrentUser() async {
    final response = await dio.get('/users/me');
    return response.data;
  }

  Future<dynamic> createUser(
    String name,
    DateTime? dateOfBaptism,
    int? groupId,
    String? phone,
    String username,
    String password,
  ) async {
    final response = await dio.post(
      '/users',
      data: {
        'name': name,
        'date_of_baptism':
            '${dateOfBaptism?.year.toString().padLeft(4, '0')}-'
            '${dateOfBaptism?.month.toString().padLeft(2, '0')}-'
            '${dateOfBaptism?.day.toString().padLeft(2, '0')}',
        'group_id': groupId,
        'phone': phone,
        'password': password,
        'username': username,
      },
    );
    return response.data;
  }

  Future<dynamic> viewUsers() async {
    final response = await dio.get('/users');
    return response.data;
  }

  Future<dynamic> logout() async {
    final response = await dio.post('/logout');
    return response.data;
  }

  Future<dynamic> deleteById(int id) async {
    final response = await dio.delete('/users/$id',);
    return response.data;
  }

  Future<dynamic> updateUser(
    int id,
    String? name,
    DateTime? dateOfBaptism,
    int? groupId,
    String? phone,
    String? username,
  ) async {
    final response = await dio.put(
      '/users/$id',
      data: {
        'name': name,
        'date_of_baptism':
            '${dateOfBaptism?.year.toString().padLeft(4, '0')}-'
            '${dateOfBaptism?.month.toString().padLeft(2, '0')}-'
            '${dateOfBaptism?.day.toString().padLeft(2, '0')}',
        'group_id': groupId,
        'phone': phone,
        'username': username,
      },
    );
    return response.data;
  }

  Future<dynamic> getUserById(int id) async {
    final response = await dio.get('/users/$id');
    return response.data;
  }
}

final usersApiProvider = Provider<UsersApi>(
  (ref) => UsersApi(ref.watch(dioProvider)),
);

final currentUserProvider = FutureProvider<dynamic>((ref) {
  final response = ref.read(usersApiProvider).getCurrentUser();
  return response;
});

final viewUsersProvider = FutureProvider<dynamic>((ref) {
  return ref.read(usersApiProvider).viewUsers();
});
