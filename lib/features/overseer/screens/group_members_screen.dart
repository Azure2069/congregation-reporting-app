import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/group/group_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(getUserRolesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Members by group')),
      body: roles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _DirectoryMessage(
          icon: Icons.lock_outline,
          title: 'Members unavailable',
          message: 'Unable to verify your role. Please try again later.',
        ),
        data: (records) {
          final roleNames = records is List
              ? records
                    .whereType<Map>()
                    .map((record) => record['role'])
                    .whereType<String>()
                    .toSet()
              : <String>{};
          if (!roleNames.contains('elder')) {
            return const _DirectoryMessage(
              icon: Icons.lock_outline,
              title: 'Access unavailable',
              message: 'You do not have access to the members directory.',
            );
          }

          final groups = ref.watch(getGroupsProvider);
          final users = ref.watch(viewUsersProvider);
          return groups.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const _DirectoryMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Groups unavailable',
              message: 'Unable to load the group list. Please try again.',
            ),
            data: (groupRecords) => users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => const _DirectoryMessage(
                icon: Icons.cloud_off_outlined,
                title: 'Members unavailable',
                message: 'Unable to load members. Please try again.',
              ),
              data: (userRecords) => _buildDirectory(
                groupRecords: groupRecords,
                userRecords: userRecords,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDirectory({
    required dynamic groupRecords,
    required dynamic userRecords,
  }) {
    if (groupRecords is! List || userRecords is! List) {
      return const _DirectoryMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Directory unavailable',
        message: 'The groups or members response could not be read.',
      );
    }

    final groups = groupRecords.whereType<Map>().toList();
    final users = userRecords.whereType<Map>().toList();
    final groupedUsers = <int, List<Map>>{};
    final unassignedUsers = <Map>[];

    for (final user in users) {
      final groupId = user['group_id'];
      if (groupId is int) {
        groupedUsers.putIfAbsent(groupId, () => <Map>[]).add(user);
      } else {
        unassignedUsers.add(user);
      }
    }

    if (groups.isEmpty && unassignedUsers.isEmpty && groupedUsers.isEmpty) {
      return const _DirectoryMessage(
        icon: Icons.people_outline,
        title: 'No members yet',
        message: 'Members will appear here when they are added.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        for (final group in groups)
          if (group['id'] is int)
            _GroupSection(
              name: group['name']?.toString() ?? 'Group ${group['id']}',
              members: groupedUsers[group['id'] as int] ?? const <Map>[],
            ),
        if (unassignedUsers.isNotEmpty)
          _GroupSection(name: 'Unassigned', members: unassignedUsers),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.name, required this.members});

  final String name;
  final List<Map> members;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '$name · ${members.length} ${members.length == 1 ? 'member' : 'members'}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (members.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'No members in this group.',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          for (final member in members)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(member['name']?.toString() ?? 'Unnamed member'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/memberReport', extra: member),
            ),
      ],
    ),
  );
}

class _DirectoryMessage extends StatelessWidget {
  const _DirectoryMessage({
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: const Color(0xFF003C33)),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
