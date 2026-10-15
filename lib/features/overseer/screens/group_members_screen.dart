import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../models/user.dart';

/*class GroupMembersScreen extends ConsumerStatefulWidget {
  const GroupMembersScreen({super.key});

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}*/

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
    final groupMembers = ref.read(userProvider.notifier).getGroupMembers(1);

    return Scaffold(
      appBar: AppBar(title: const Text('Group members')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: groupMembers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(groupMembers[index].name),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final role in groupMembers[index].roles)
                      _RoleChip(label: _roleLabel(role)),
                    _RoleChip(
                      label: _serviceTypeLabel(groupMembers[index].serviceType),
                      outlined: true,
                    ),
                  ],
                ),
              ),
              leading: CircleAvatar(
                child: Text(groupMembers[index].name.substring(0, 1)),
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF211F54),
              ),
              onTap: () {
                context.push('/memberReport', extra: groupMembers[index]);
              },
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.publisher:
        return 'Publisher';
      case UserRole.groupOverseer:
        return 'Group overseer';
      case UserRole.secretary:
        return 'Secretary';
      case UserRole.elder:
        return 'Elder';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String _serviceTypeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.publisher:
        return 'Publisher';
      case ServiceType.auxiliaryPioneer:
        return 'Auxiliary pioneer';
      case ServiceType.regularPioneer:
        return 'Regular pioneer';
    }
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, this.outlined = false});

  final String label;
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
      label,
      style: const TextStyle(
        color: Color(0xFF211F54),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
