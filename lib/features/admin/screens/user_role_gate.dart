import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';

class UserRoleGate extends ConsumerStatefulWidget {
  const UserRoleGate({
    super.key,
    required this.requiredRoles,
    required this.child,
  });

  final Set<String> requiredRoles;
  final Widget child;

  @override
  ConsumerState<UserRoleGate> createState() => _UserRoleGateState();
}

class _UserRoleGateState extends ConsumerState<UserRoleGate> {
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final user = await ref.read(getcurrentUserProvider.future);
      final userId = user is Map ? user['id'] : null;
      if (userId is! int) throw StateError('Current user id is unavailable');

      final response = await ref.read(getAllUserRolesProvider(userId).future);
      final roles = response is List
          ? response
                .whereType<Map>()
                .map((row) => row['role'])
                .whereType<String>()
                .toSet()
          : <String>{};
      final allowed = widget.requiredRoles.every(roles.contains);
      if (!mounted) return;
      if (!allowed) {
        context.go('/home');
        return;
      }
      setState(() => _authorized = true);
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
