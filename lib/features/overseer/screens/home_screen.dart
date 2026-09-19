import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OverseerHomeScreen extends ConsumerWidget {
  const OverseerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.push("/allMembers");
                },
                child: Text("👥 View Group Members"),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  context.push("/submitReport");
                },
                child: Text("📝 Submit Report "),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  context.push("/currentReports");
                },
                child: Text("📅 Current Month Report "),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                
                onPressed: () {
                  context.push("/allReports");
                },
                child: Text("📚 All Reports "))
            ],
          ),
        ),
      ),
    );
  }
}
