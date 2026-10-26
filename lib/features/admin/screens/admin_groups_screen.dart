import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/group/group_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';
import 'admin_access_gate.dart';

class AdminGroupsScreen extends ConsumerWidget {
  const AdminGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdminAccessGate(
    child: Scaffold(
      appBar: AppBar(title: const Text('Manage groups')),
      body: FutureBuilder<dynamic>(
        future: ref.watch(getGroupsProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Unable to load groups: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(getGroupsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          final groups = snapshot.data is List
              ? snapshot.data as List
              : const [];
          return Column(
            children: [
              FutureBuilder<dynamic>(
                future: ref.read(getcurrentUserProvider.future),
                builder: (context, userSnapshot) {
                  final userId = userSnapshot.data is Map
                      ? _toInt(userSnapshot.data['id'])
                      : null;
                  if (userId == null) return const SizedBox.shrink();
                  return FutureBuilder<dynamic>(
                    future: ref.read(getAllUserRolesProvider(userId).future),
                    builder: (context, roleSnapshot) {
                      final roles = roleSnapshot.data is List
                          ? roleSnapshot.data as List
                          : const [];
                      final canAdd =
                          roles.whereType<Map>().any(
                            (r) => r['role'] == 'admin',
                          ) &&
                          roles.whereType<Map>().any(
                            (r) => r['role'] == 'elder',
                          );
                      if (!canAdd) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: () => _addGroup(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Add group'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              Expanded(
                child: groups.isEmpty
                    ? const Center(child: Text('No groups found.'))
                    : RefreshIndicator(
                        onRefresh: () => ref.refresh(getGroupsProvider.future),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            if (group is! Map) return const SizedBox.shrink();
                            final id = _toInt(group['id'] ?? group['group_id']);
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.groups_outlined),
                                ),
                                title: Text(
                                  '${group['name'] ?? group['group_name'] ?? 'Group ${id ?? ''}'}',
                                ),
                                subtitle: Text(
                                  'Overseer ID: ${group['overseer_id'] ?? group['group_overseer_id'] ?? 'Unassigned'}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (choice) {
                                    if (id == null) return;
                                    if (choice == 'assign')
                                      _assignOverseer(context, ref, id);
                                    if (choice == 'delete')
                                      _deleteGroup(
                                        context,
                                        ref,
                                        id,
                                        '${group['name'] ?? 'this group'}',
                                      );
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'assign',
                                      child: Text('Assign overseer'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete group'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Future<void> _addGroup(BuildContext context, WidgetRef ref) async {
  var groupName = '';
  String? validationError;
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Add group'),
        content: TextField(
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            groupName = value;
            if (validationError != null) {
              setDialogState(() => validationError = null);
            }
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(dialogContext, value.trim());
            } else {
              setDialogState(() => validationError = 'Enter a group name');
            }
          },
          decoration: InputDecoration(
            labelText: 'Group name',
            errorText: validationError,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (groupName.trim().isNotEmpty) {
                Navigator.pop(dialogContext, groupName.trim());
              } else {
                setDialogState(() => validationError = 'Enter a group name');
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
  if (name == null) return;
  try {
    // Create without an overseer; the backend validates overseer membership against the new group.
    await ref.read(groupApiProvider).addGroup(name, null);
    ref.invalidate(getGroupsProvider);
  } catch (error) {
    if (context.mounted) _showError(context, error);
  }
}

Future<void> _assignOverseer(
  BuildContext context,
  WidgetRef ref,
  int groupId,
) async {
  final usersFuture = ref.read(viewUsersProvider.future);
  final users = await usersFuture;
  if (!context.mounted) return;
  final groupMembers = users is List
      ? users
            .whereType<Map>()
            .where(
              (u) =>
                  _toInt(u['id']) != null && _toInt(u['group_id']) == groupId,
            )
            .toList()
      : <Map>[];
  final candidates = <Map>[];
  for (final member in groupMembers) {
    final userId = _toInt(member['id'])!;
    try {
      final roles = await ref.read(getAllUserRolesProvider(userId).future);
      final names = roles is List
          ? roles
                .whereType<Map>()
                .map((role) => role['role'])
                .whereType<String>()
                .toSet()
          : <String>{};
      if (names.contains('elder') && !names.contains('group_overseer')) {
        candidates.add(member);
      }
    } catch (_) {
      // Skip members whose role records cannot be checked.
    }
  }
  if (!context.mounted) return;
  if (candidates.isEmpty) {
    _showError(
      context,
      Exception('No eligible elder in this group is available.'),
    );
    return;
  }
  int? selected;
  final chosen = await showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Assign group overseer'),
        content: DropdownButtonFormField<int>(
          value: selected,
          decoration: const InputDecoration(labelText: 'Member in this group'),
          items: [
            for (final user in candidates)
              DropdownMenuItem(
                value: _toInt(user['id']),
                child: Text(
                  '${user['name'] ?? user['username'] ?? 'User ${user['id']}'} (group ${user['group_id'] ?? '—'})',
                ),
              ),
          ],
          onChanged: (value) => setState(() => selected = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: selected == null
                ? null
                : () => Navigator.pop(dialogContext, selected),
            child: const Text('Assign'),
          ),
        ],
      ),
    ),
  );
  if (chosen == null) return;
  try {
    await ref.read(groupApiProvider).updateOverseer(groupId, chosen);
    ref.invalidate(getGroupsProvider);
  } catch (error) {
    if (context.mounted) _showError(context, error);
  }
}

Future<void> _deleteGroup(
  BuildContext context,
  WidgetRef ref,
  int id,
  String name,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete group?'),
      content: Text(
        'Delete $name? The backend may reject this if members are still assigned.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(groupApiProvider).deleteGroup(id);
    ref.invalidate(getGroupsProvider);
  } catch (error) {
    if (context.mounted) _showError(context, error);
  }
}

int? _toInt(dynamic value) => value is int ? value : int.tryParse('$value');
void _showError(BuildContext context, Object error) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not complete that action: $error')),
    );
