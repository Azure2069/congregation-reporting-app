enum ServiceType { publisher, auxiliaryPioneer, regularPioneer }

enum UserRole { publisher, groupOverseer, secretary, elder, admin }

class User {
  String userId;
  String name;
  List<UserRole> roles;
  ServiceType serviceType;
  int groupId;

  User({
    required this.userId, required this.name, required this.roles, required this.serviceType, required this.groupId
  });
}
