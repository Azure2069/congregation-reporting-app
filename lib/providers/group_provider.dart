import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/group.dart';
import '../models/user.dart';

class GroupNotifier extends Notifier<List<Group>> {
  
  @override
  List<Group> build() {
    return [
      Group(
      groupId: 1,
      groupName: "Group 1",
      groupOverseerId: 5,
    ),
    Group(
      groupId: 2,
      groupName: "Group 2",
      groupOverseerId: 6,
    ),
    Group(
      groupId: 3,
      groupName: "Group 3",
      groupOverseerId: 7,
    ),
    ];
  }/*
  void loadDummyGroups() {
    state = [
      Group(groupId: 1, groupName: "Group 1", groupOverseerId: 5),
      Group(groupId: 2, groupName: "Group 2", groupOverseerId: 6),
      Group(groupId: 3, groupName: "Group 3", groupOverseerId: 7),
    ];
  }
*/


    }



final groupProvider = NotifierProvider<GroupNotifier, List<Group>>
(GroupNotifier.new);
