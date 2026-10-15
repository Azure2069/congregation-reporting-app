import 'package:dio/dio.dart';

import '../network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupApi {
  final Dio dio;
  GroupApi(this.dio);
  Future<dynamic> getGroups() async {
    final response = await dio.get('/groups');
    return response.data;
  }

  Future<dynamic> getGroupMembers() async {
    final response = await dio.get('/groups/my_group_members');
    return response.data;
  }

  Future<dynamic> addGroup(String name, int? overseerId) async {
    final response = await dio.post(
      "/groups",
      data: {'name': name, 'overseer_id': overseerId},
    );
    return response.data;
  }

  Future<dynamic> updateOverseer(int groupId, int overseerId) async {
    final response = await dio.patch(
      'groups/$groupId/overseer',
      queryParameters: {'new_overseer_id': overseerId},
    );
    return response.data;
  }

  Future<dynamic> getGroupById(int groupID) async {
    final response = await dio.get('/groups/$groupID');
    return response.data;
  }
  Future<dynamic> deleteGroup(int groupId) async {
    final response = await dio.delete('/groups/$groupId');
    return response.data;
  }
}

final groupApiProvider = Provider<GroupApi>(
  (ref) => GroupApi(ref.watch(dioProvider)),
);

final getGroupsProvider = FutureProvider<dynamic>(
  (ref) => ref.watch(groupApiProvider).getGroups(),
);

final getGroupMembersProvider = FutureProvider<dynamic>(
  (ref) => ref.watch(groupApiProvider).getGroupMembers(),
);
final getGroupByIdProvider=FutureProvider.family<dynamic, int>(
  (ref, groupId) => ref.watch(groupApiProvider).getGroupById(groupId),
);