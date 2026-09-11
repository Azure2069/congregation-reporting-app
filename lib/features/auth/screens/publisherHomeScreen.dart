import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublisherHomeScreen extends StatefulWidget {
  const PublisherHomeScreen({super.key});

  @override
  State<PublisherHomeScreen> createState() => _PublisherHomeScreen();
}

class _PublisherHomeScreen extends State<PublisherHomeScreen> {
  final name = 'Isaac';
  final month = 'January 2025';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Congregation Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: const Color(0xFF647773)),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF173B38),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly report',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1D6),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Not submitted',
                            style: TextStyle(
                              color: Color(0xFF8A5B12),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      month,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF173B38),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Baptized Publisher',
                      style: TextStyle(color: Color(0xFF647773)),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/submitReport'),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Submit report'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF176B62),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Service status',
                            style: TextStyle(
                              color: Color(0xFF647773),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Publisher',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => context.push('/reportHistory'),
                      child: const Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: Color(0xFF176B62),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Report history',
                              style: TextStyle(
                                color: Color(0xFF647773),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View reports',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Recent report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF173B38),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your submitted reports will appear here.',
              style: TextStyle(color: Color(0xFF647773)),
            ),
          ],
        ),
      ),
    );
  }
}
