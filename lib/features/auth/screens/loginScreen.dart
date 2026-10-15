import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/token_provider.dart';
import '../../../core/api/users/users_api.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 74,
                width: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  size: 36,
                  color: Color(0xFF529FCB),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Congregation reporting',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF222121),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your monthly ministry report.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF555555)),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  hintText: "Enter your username",
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
              ),

              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final response = await ref.read(usersApiProvider).login(
                    usernameController.text,
                    passwordController.text
                  );
                  final token = response.data['session_token'];
                  ref.read(authTokenProvider.notifier).state = token;
                  if (token != null) {
                    context.go('/home');
                  }
                },

                // => context.go('/home'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue'),
              ),
              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  context.push('/overseerHome');
                },
                child: Text("Overseer Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
