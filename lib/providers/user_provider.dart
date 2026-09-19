import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

class UserNotifier extends Notifier<List<User>> {
  @override
  List<User> build() {
    return [

    User(
      userId: "1",
      groupId: 1,
      serviceType: ServiceType.publisher,
      name: "Isaac",
      roles: [UserRole.publisher],
     
    ),
    User(
      userId: "2",
      groupId: 1,
      name: "Collins Ameyaw",
      roles: [
        UserRole.secretary,
        UserRole.elder,
        UserRole.publisher,
      ],
      serviceType: ServiceType.publisher,
    ),
    User(   
      userId: "3",
      groupId: 1,
      name: "Henrietta Cobbinah",
      roles: [UserRole.publisher],
      serviceType: ServiceType.publisher,
    ),
    User(
      userId: "4",
      groupId: 1,
      name: "Naomi Essuman",
      roles: [UserRole.publisher],
      serviceType: ServiceType.regularPioneer,
    ),
    User(
      userId: "5",
      groupId: 1,
        name: "Enoch Owusu",
      roles: [
        UserRole.groupOverseer,
        UserRole.elder,
      ],
      serviceType: ServiceType.publisher,
    ),
  ];
}
   

/*
  void loadDummyUsers() {
    state = [
      User(
        groupId: 1,
        serviceType: ServiceType.publisher,
        name: "Isaac",
        roles: [UserRole.publisher],
        id: 1,
      ),
      User(
        groupId: 1,
        name: "Collins Ameyaw",
        roles: [UserRole.secretary, UserRole.elder, UserRole.publisher],
        serviceType: ServiceType.publisher,
        id: 2,
      ),
      User(
        groupId: 1,
        id: 3,
        name: "Henrietta Cobbinah",
        roles: [UserRole.publisher],
        serviceType: ServiceType.publisher,
      ),
      User(
        groupId: 1,
        id: 4,
        name: "Naomi Essuman",
        roles: [UserRole.publisher],
        serviceType: ServiceType.regularPioneer,
      ),
      User(
        groupId: 1,
        id: 5,
        name: "Enoch Owusu",
        roles: [UserRole.groupOverseer, UserRole.elder],
        serviceType: ServiceType.publisher,
      ),
    ];
  }
*/
  List<User> getGroupMembers(int groupId) {
    //loadDummyUsers();
    return state
        .where((existingUser) => existingUser.groupId == groupId)
        .toList();
  }
}

final userProvider = NotifierProvider<UserNotifier, List<User>>(
  UserNotifier.new,
);
