import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/token_provider.dart';
import '../../../core/api/users/users_api.dart';

class AuthCheckScreen extends ConsumerWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<void>(
      future: ref.read(restoreTokenProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = ref.read(authTokenProvider);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;

          if (token == null || token.isEmpty) {
            context.go('/login');
            return;
          }

          try {
            await ref.read(usersApiProvider).getCurrentUser();

            if (context.mounted) {
              context.go('/home');
            }
          } catch (_) {
            await ref.read(tokenStorageProvider).deleteToken();
            ref.read(authTokenProvider.notifier).state = null;

            if (context.mounted) {
              context.go('/login');
            }
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}