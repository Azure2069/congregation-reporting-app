import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/date_labels.dart';
import '../providers/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/users/users_api.dart';

class PublisherHomeScreen extends ConsumerStatefulWidget {
  const PublisherHomeScreen({super.key});

  @override
  ConsumerState<PublisherHomeScreen> createState() => _PublisherHomeScreen();
}

class _PublisherHomeScreen extends ConsumerState<PublisherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final reportingMonth = DateLabels.currentReportingMonth();
    return Scaffold(
      appBar: AppBar(title: const Text('Congregation Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            currentUser.when(
              loading: () => const CircularProgressIndicator(),
              error: ((error, stackTrace) {
                if (error is DioException &&
                    error.response?.statusCode == 401) {
                  ref.read(authTokenProvider.notifier).state = null;
                }
                if (ref.read(authTokenProvider.notifier).state == null) {
                  context.pop();
                }
                return const Text('Failed to load your profile.');
              }),
              data: (response) {
                final user = response.data;
                return Text(
                  'Welcome, ${user['name']}!',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            Text(
              'MONTHLY MINISTRY',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: const Color(0xFF555555)),
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
                            color: const Color(0xFFEAF5FB),
                            borderRadius: BorderRadius.circular(20),
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
                      DateLabels.monthYear(reportingMonth),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF222121),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Baptized Publisher',
                      style: TextStyle(color: Color(0xFF555555)),
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
                            color: Color(0xFF529FCB),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Service status',
                            style: TextStyle(
                              color: Color(0xFF555555),
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
                              color: Color(0xFF529FCB),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Report history',
                              style: TextStyle(
                                color: Color(0xFF555555),
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
                color: const Color(0xFF222121),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your submitted reports will appear here.',
              style: TextStyle(color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }
}
