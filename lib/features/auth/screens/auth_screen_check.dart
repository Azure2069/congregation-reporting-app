import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/users/users_api.dart';
import '../providers/token_provider.dart';

class AuthCheckScreen extends ConsumerStatefulWidget {
  const AuthCheckScreen({super.key, this.redirectTo});
  final String? redirectTo;

  @override
  ConsumerState<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends ConsumerState<AuthCheckScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _verifySession();
    }
  }

  Future<void> _verifySession() async {
    try {
      await ref.read(restoreTokenProvider.future);
      final token = ref.read(authTokenProvider);
      if (token == null || token.isEmpty) {
        if (mounted) context.go(_loginLocation());
        return;
      }
      await ref.read(usersApiProvider).getCurrentUser();
      if (mounted) context.go(_safeDestination(widget.redirectTo));
    } catch (_) {
      await ref.read(tokenStorageProvider).deleteToken();
      ref.read(authTokenProvider.notifier).state = null;
      if (mounted) context.go(_loginLocation());
    }
  }

  String _loginLocation() {
    final destination = _safeDestination(widget.redirectTo);
    return Uri(
      path: '/login',
      queryParameters: {'redirectTo': destination},
    ).toString();
  }

  String _safeDestination(String? destination) {
    if (destination == null ||
        !destination.startsWith('/') ||
        destination.startsWith('//')) {
      return '/home';
    }
    if (destination == '/auth-check' || destination.startsWith('/login'))
      return '/home';
    return destination;
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
