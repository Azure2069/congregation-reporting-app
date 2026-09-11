import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreen();
}

class _ReportHistoryScreen extends State<ReportHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report History")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Your reports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF173B38),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A record of your monthly submissions.',
            style: TextStyle(color: Color(0xFF647773)),
          ),
          const SizedBox(height: 22),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              onTap: () {
                context.push('/report-details');
              },
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD9EEE8),
                child: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF176B62),
                  size: 19,
                ),
              ),
              title: Text("January 2025"),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('No Report Details'),
              ),
              trailing: const Chip(label: Text("Not submitted")),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD9EEE8),
                child: Icon(
                  Icons.calendar_month,
                  color: Color(0xFF176B62),
                  size: 19,
                ),
              ),
              title: Text("December 2025"),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("No Report Detail"),
              ),
              trailing: const Chip(label: Text("Not submitted")),
            ),
          ),
        ],
      ),
    );
  }
}
