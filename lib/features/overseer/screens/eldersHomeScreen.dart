import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OverseerHomeScreen extends ConsumerWidget {
  const OverseerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overseer desk')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Review activity and support each member with a clear monthly view.',
                style: TextStyle(color: Color(0xFF555555), height: 1.5),
              ),
              const SizedBox(height: 28),
              _DeskAction(
                icon: Icons.groups_outlined,
                title: 'Group members',
                detail: 'View member profiles and history',
                onTap: () => context.push('/allMembers'),
              ),
              const SizedBox(height: 12),
              _DeskAction(
                icon: Icons.calendar_month_outlined,
                title: 'Current month',
                detail: 'Review reports received this month',
                onTap: () => context.push('/currentReports'),
              ),
              const SizedBox(height: 12),
              _DeskAction(
                icon: Icons.library_books_outlined,
                title: 'All reports',
                detail: 'Browse reports by group member',
                onTap: () => context.push('/allReports'),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => context.push('/submitReport'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Submit a report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeskAction extends StatelessWidget {
  const _DeskAction({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF529FCB)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(color: Color(0xFF555555)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF211F54)),
          ],
        ),
      ),
    ),
  );
}
