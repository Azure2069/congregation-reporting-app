import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/users/users_api.dart';
import '../../../core/api/user_role/user_role_api.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() =>
      _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Member roles')),
    body: ref
        .watch(viewUsersProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _LoadError(
            message: _errorMessage(error),
            onRetry: () => ref.invalidate(viewUsersProvider),
          ),
          data: (response) {
            final users = response is List
                ? response.whereType<Map>().toList()
                : <Map>[];
            final filtered =
                users.where((user) {
                  final name = '${user['name'] ?? ''}'.toLowerCase();
                  final username = '${user['username'] ?? ''}'.toLowerCase();
                  return name.contains(_query) || username.contains(_query);
                }).toList()..sort(
                  (a, b) => '${a['name'] ?? ''}'.toLowerCase().compareTo(
                    '${b['name'] ?? ''}'.toLowerCase(),
                  ),
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign congregation roles',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add or remove member roles in your congregation. Only active role assignments can be removed here.',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _query = value.trim().toLowerCase()),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Find a member',
                          hintText: 'Search by name or username',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const _EmptyMembers()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final member = filtered[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFEDFCE9),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF003C33),
                                  ),
                                ),
                                title: Text(
                                  '${member['name'] ?? 'Unnamed member'}',
                                ),
                                subtitle: Text(
                                  member['group_id'] == null
                                      ? '${member['username'] ?? ''}'
                                      : 'Group ${member['group_id']} · ${member['username'] ?? ''}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => showDialog<void>(
                                  context: context,
                                  builder: (_) =>
                                      _MemberRoleDialog(member: member),
                                ),
                              ),
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

class _MemberRoleDialog extends ConsumerStatefulWidget {
  const _MemberRoleDialog({required this.member});
  final Map member;

  @override
  ConsumerState<_MemberRoleDialog> createState() => _MemberRoleDialogState();
}

class _MemberRoleDialogState extends ConsumerState<_MemberRoleDialog> {
  static const _assignableRoles = <String, String>{
    'publisher': 'Publisher',
    'elder': 'Elder',
    'secretary': 'Secretary',
    'service_overseer': 'Service overseer',
  };

  String? _selectedRole;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final userId = _id(widget.member['id']);
    if (userId == null) {
      return const AlertDialog(
        title: Text('Member roles'),
        content: Text('This member does not have a valid user id.'),
      );
    }

    final rolesAsync = ref.watch(getAllUserRolesProvider(userId));
    return AlertDialog(
      title: Text('${widget.member['name'] ?? 'Member'}’s roles'),
      content: SizedBox(
        width: 420,
        child: rolesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Text('Could not load current roles: ${_errorMessage(error)}'),
          data: (response) {
            final rows = response is List
                ? response.whereType<Map>().toList()
                : <Map>[];
            final roleNames = rows
                .map((row) => row['role'])
                .whereType<String>()
                .toSet();
            final available = _assignableRoles.keys
                .where((role) => !roleNames.contains(role))
                .toList();
            final removable = rows.where((row) {
              final role = row['role'];
              return role is String && _assignableRoles.containsKey(role);
            }).toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current roles'),
                const SizedBox(height: 10),
                if (roleNames.isEmpty)
                  const Text(
                    'No roles are assigned yet.',
                    style: TextStyle(color: Color(0xFF616161)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: removable.map((row) {
                      final role = '${row['role']}';
                      return InputChip(
                        label: Text(_roleLabel(role)),
                        backgroundColor: const Color(0xFFEDFCE9),
                        side: BorderSide.none,
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: _saving || _removeDisabled(row)
                            ? null
                            : () => _removeRole(userId, row),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                if (available.isEmpty)
                  const Text(
                    'There are no additional roles available to assign.',
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    value: available.contains(_selectedRole)
                        ? _selectedRole
                        : null,
                    decoration: const InputDecoration(labelText: 'Role to add'),
                    items: available
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(_roleLabel(role)),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _selectedRole = value),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Group overseer is assigned from Group management. Admin, coordinator, and circuit overseer roles cannot be assigned here.',
                    style: TextStyle(
                      color: Color(0xFF75758A),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Done'),
        ),
        FilledButton(
          onPressed: _saving || _selectedRole == null
              ? null
              : () => _assignRole(userId, _selectedRole!),
          child: Text(_saving ? 'Assigning…' : 'Assign role'),
        ),
      ],
    );
  }

  Future<void> _assignRole(int userId, String role) async {
    setState(() => _saving = true);
    try {
      await ref.read(userRoleApiProvider).addRole(userId, role);
      ref.invalidate(getAllUserRolesProvider(userId));
      if (!mounted) return;
      setState(() => _selectedRole = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_roleLabel(role)} role assigned.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not assign role: ${_errorMessage(error)}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeRole(int userId, Map row) async {
    final role = row['role'];
    if (role is! String || !_assignableRoles.containsKey(role)) {
      return;
    }

    setState(() => _saving = true);
    try {
      final roleId = row['id'];
      if (roleId != null) {
        await ref.read(userRoleApiProvider).deleteRole(_id(roleId) ?? -1);
      } else {
        await ref
            .read(userRoleApiProvider)
            .deleteRole(_id(row['user_role_id']) ?? -1);
      }
      ref.invalidate(getAllUserRolesProvider(userId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_roleLabel(role)} role removed.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove role: ${_errorMessage(error)}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _removeDisabled(Map row) {
    final id = row['id'] ?? row['user_role_id'];
    return _id(id) == null;
  }
}

String _roleLabel(String role) => switch (role) {
  'group_overseer' => 'Group overseer',
  'service_overseer' => 'Service overseer',
  'circuit_overseer' => 'Circuit overseer',
  _ =>
    role.isEmpty
        ? 'Unknown role'
        : '${role[0].toUpperCase()}${role.substring(1)}',
};

int? _id(dynamic value) => value is int ? value : int.tryParse('$value');

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) return '${data['detail']}';
    return error.message ?? 'Please try again.';
  }
  return '$error';
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('No members match that search.'),
    ),
  );
}
