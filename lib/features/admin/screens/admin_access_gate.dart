import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';

class AdminAccessGate extends ConsumerStatefulWidget {
  const AdminAccessGate({
    super.key,
    required this.child,
    this.allowElder = false,
  });
  final Widget child;
  final bool allowElder;

  @override
  ConsumerState<AdminAccessGate> createState() => _AdminAccessGateState();
}

class _AdminAccessGateState extends ConsumerState<AdminAccessGate> {
  bool? _authorized;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final user = await ref.read(getcurrentUserProvider.future);
      final roles = await ref.read(
        getAllUserRolesProvider(user['id'] as int).future,
      );
      final names = roles is List
          ? roles
                .whereType<Map>()
                .map((row) => row['role'])
                .whereType<String>()
                .toSet()
          : <String>{};
      final allowed = widget.allowElder
          ? names.contains('elder')
          : names.contains('admin');
      if (!mounted) return;
      setState(() => _authorized = allowed);
      if (!allowed) context.go('/home');
    } catch (_) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized != true) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
