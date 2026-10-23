import 'package:congregation_reporting/core/api/service_assignments/service_assignments_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_labels.dart';
import '../../../providers/user_provider.dart';
import '../../../models/user.dart';
import '../../../core/api/group/group_api.dart';
import '../../../core/api/group/group_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key});
  /*@override
  void initState() {
    super.initState();
    ref.read(userProvider.notifier).loadDummyUsers();
    ref.read(groupProvider.notifier).loadDummyGroups();
  }
  */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupMembers = ref.watch(getGroupMembersProvider);
    final currentMonth = DateLabels.currentReportingMonth();
    final currentUser = ref.watch(getcurrentUserProvider);
    
    return Scaffold(
      appBar: AppBar(title: currentUser.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const Text("Unable to display group name"),
      data: (user){
        final groupId=user['group_id'];
        final groupName=ref.watch(getGroupByIdProvider(groupId));
        return groupName.when(
        loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const Text("Unable to display group name"),
      data: (groupName)=>Text('${groupName['name']} Members')


        );
        


      }
      ),),
      body: groupMembers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _StateMessage(
          icon: Icons.people_outline,
          title: 'Members unavailable',
          message: 'Unable to load group members. Please try again later.',
        ),
        data: (members) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.groups_2_outlined,
                        color: Color(0xFF211F54),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your group',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${members.length} ${members.length == 1 ? 'member' : 'members'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: members.isEmpty
                    ? const _StateMessage(
                        icon: Icons.person_search_outlined,
                        title: 'No group members yet',
                        message:
                            'Members will appear here when they are added to your group.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final serviceAssignment = ref.watch(
                            checkServiceAssignmentProvider((
                              members[index]['id'],
                              currentMonth,
                            )),
                          );

                          return serviceAssignment.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: LinearProgressIndicator(),
                            ),
                            error: (error, stackTrace) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: _StateMessage(
                                icon: Icons.assignment_outlined,
                                title: 'Assignments unavailable',
                                message:
                                    'Unable to load this member’s assignments.',
                              ),
                            ),
                            data: (assignments) {
                              final allAssignments = [];

                              for (int i = 0; i < assignments.length; i++) {
                                allAssignments.add(
                                  assignments[i]['service_type'],
                                );
                              }
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  minVerticalPadding: 16,
                                  title: Text(
                                    members[index]['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ROLE & SERVICE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 1.1,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        ref
                                            .watch(
                                              getAllUserRolesProvider(
                                                members[index]['id'],
                                              ),
                                            )
                                            .when(
                                              loading: () => const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                              error: (error, stackTrace) =>
                                                  const Text(
                                                    'Unable to load roles',
                                                  ),
                                              data: (roles) {
                                                final allRoles = [];
                                                for (
                                                  int i = 0;
                                                  i < roles.length;
                                                  i++
                                                ) {
                                                  allRoles.add(
                                                    roles[i]['role'],
                                                  );
                                                }

                                                return Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: [
                                                    ..._roleLabel(allRoles).map(
                                                      (role) => _RoleChip(
                                                        label: [role],
                                                      ),
                                                    ),
                                                    ..._serviceTypeLabel(
                                                      allAssignments,
                                                    ).map(
                                                      (type) => _RoleChip(
                                                        label: [type],
                                                        outlined: true,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                      ],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFFEAF5FB),
                                    foregroundColor: const Color(0xFF211F54),
                                    child: Text(
                                      members[index]['name']
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF211F54),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onTap: () {
                                    context.push(
                                      '/memberReport',
                                      extra: members[index],
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List _roleLabel(List roles) {
    for (int i = 0; i < roles.length; i++) {
      if (roles[i] == 'publisher') {
        roles[i] = 'Publisher';
      } else if (roles[i] == 'group_overseer') {
        roles[i] = 'Group Overseer';
      } else if (roles[i] == 'elder') {
        roles[i] = 'Elder';
      } else if (roles[i] == 'service_overseer') {
        roles[i] = 'Service Overseer';
      } else if (roles[i] == 'coordinator') {
        roles[i] = 'Coordinator';
      } else if (roles[i] == 'admin') {
        roles[i] = 'Admin';
      } else if (roles[i] == 'circuit_overseer') {
        roles[i] = 'Circuit Overseer';
      }
    }
    return roles;
  }

  List _serviceTypeLabel(List type) {
    for (int i = 0; i < type.length; i++) {
      if (type[i] == 'publisher') {
        type[i] = 'Publisher';
      } else if (type[i] == 'auxiliary_pioneer') {
        type[i] = 'Auxiliary Pioneer';
      } else if (type[i] == 'regular_pioneer') {
        type[i] = 'Regular pioneer';
      }
    }
    return type;
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: const Color(0xFF529FCB)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.outlined = false});

  final List label;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: outlined ? Colors.white : const Color(0xFFEAF5FB),
      borderRadius: BorderRadius.circular(20),
      border: outlined ? Border.all(color: const Color(0xFFD5D5D5)) : null,
    ),
    child: Text(
      label.join(', '),
      style: const TextStyle(
        color: Color(0xFF211F54),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
