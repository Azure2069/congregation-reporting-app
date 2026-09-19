import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final dateController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    dateController.dispose();
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone number",
                  hintText: "0xxxxxxxxx",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: "Baptism year",
                  hintText: "YYYY",
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),

              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
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
