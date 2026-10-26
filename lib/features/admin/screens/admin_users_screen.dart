import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/group/group_api.dart';
import '../../../core/api/users/users_api.dart';
import 'admin_access_gate.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AdminAccessGate(
    child: Scaffold(
      appBar: AppBar(title: const Text('Manage members')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserForm(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add member'),
      ),
      body: FutureBuilder<dynamic>(
        future: ref.watch(viewUsersProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return _ErrorView(
              error: snapshot.error,
              onRetry: () => ref.invalidate(viewUsersProvider),
            );
          final users = snapshot.data is List
              ? snapshot.data as List
              : const [];
          if (users.isEmpty)
            return const Center(child: Text('No members found.'));
          return RefreshIndicator(
            onRefresh: () => ref.refresh(viewUsersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                if (user is! Map) return const SizedBox.shrink();
                final id = _asInt(user['id']);
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text('${user['name'] ?? 'Unnamed member'}'),
                    subtitle: Text(
                      [
                        if (user['username'] != null) '${user['username']}',
                        if (user['group_id'] != null)
                          'Group ${user['group_id']}',
                      ].join(' · '),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit')
                          _showUserForm(context, ref, user: user);
                        if (action == 'delete' && id != null)
                          _deleteUser(
                            context,
                            ref,
                            id,
                            '${user['name'] ?? 'this member'}',
                          );
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _showUserForm(
  BuildContext context,
  WidgetRef ref, {
  Map? user,
}) async {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: user?['name']?.toString() ?? '');
  final username = TextEditingController(
    text: user?['username']?.toString() ?? '',
  );
  final phone = TextEditingController(text: user?['phone']?.toString() ?? '');
  final password = TextEditingController();
  final baptism = TextEditingController(
    text: user?['date_of_baptism']?.toString() ?? '',
  );
  final groupsFuture = ref.read(getGroupsProvider.future);
  int? groupId = _asInt(user?['group_id']);
  bool saving = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(user == null ? 'Add member' : 'Edit member'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a username'
                        : null,
                  ),
                  if (user == null) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Temporary password',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter a password' : null,
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: baptism,
                    decoration: const InputDecoration(
                      labelText: 'Baptism date (YYYY-MM-DD, optional)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return DateTime.tryParse(v.trim()) == null
                          ? 'Use YYYY-MM-DD'
                          : null;
                    },
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<dynamic>(
                    future: groupsFuture,
                    builder: (context, snapshot) {
                      final groups = snapshot.data is List
                          ? snapshot.data as List
                          : const [];
                      return DropdownButtonFormField<int?>(
                        value:
                            groups.any(
                              (g) => g is Map && _asInt(g['id']) == groupId,
                            )
                            ? groupId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Group (optional)',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('No group'),
                          ),
                          for (final g in groups.whereType<Map>())
                            if (_asInt(g['id']) != null)
                              DropdownMenuItem<int?>(
                                value: _asInt(g['id']),
                                child: Text(
                                  '${g['name'] ?? 'Group ${g['id']}'}',
                                ),
                              ),
                        ],
                        onChanged: (value) =>
                            setDialogState(() => groupId = value),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setDialogState(() => saving = true);
                    try {
                      final date = baptism.text.trim().isEmpty
                          ? null
                          : DateTime.parse(baptism.text.trim());
                      if (user == null) {
                        await ref
                            .read(usersApiProvider)
                            .createUser(
                              name.text.trim(),
                              date,
                              groupId,
                              _nullable(phone.text),
                              username.text.trim(),
                              password.text,
                            );
                      } else {
                        final id = _asInt(user['id']);
                        if (id == null) throw Exception('Member id is missing');
                        await ref
                            .read(usersApiProvider)
                            .updateUser(
                              id,
                              name.text.trim(),
                              date,
                              groupId,
                              _nullable(phone.text),
                              username.text.trim(),
                            );
                      }
                      ref.invalidate(viewUsersProvider);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    } catch (error) {
                      if (dialogContext.mounted)
                        _showError(dialogContext, error);
                    } finally {
                      if (dialogContext.mounted)
                        setDialogState(() => saving = false);
                    }
                  },
            child: Text(saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    ),
  );
  name.dispose();
  username.dispose();
  phone.dispose();
  password.dispose();
  baptism.dispose();
}

Future<void> _deleteUser(
  BuildContext context,
  WidgetRef ref,
  int id,
  String name,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete member?'),
      content: Text('Delete $name and their account?'),
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
    await ref.read(usersApiProvider).deleteById(id);
    ref.invalidate(viewUsersProvider);
  } catch (error) {
    if (context.mounted) _showError(context, error);
  }
}

String? _nullable(String value) => value.trim().isEmpty ? null : value.trim();
int? _asInt(dynamic value) => value is int ? value : int.tryParse('$value');
void _showError(BuildContext context, Object error) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not complete that action: $error')),
    );

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Unable to load members: $error'),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
