import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/reports/reports_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/utils/date_labels.dart';

class MemberReportsScreen extends ConsumerWidget {
  final Map member;
  const MemberReportsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(getUserRolesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Reports for ${member['name']}')),
      body: roles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to verify your role.'),
        ),
        data: (roleRecords) {
          final roleNames = roleRecords is List
              ? roleRecords
                    .whereType<Map>()
                    .map((record) => record['role'])
                    .whereType<String>()
                    .toSet()
              : <String>{};
          if (!roleNames.contains('elder')) {
            return const Center(
              child: Text('You do not have access to member reports.'),
            );
          }
          final reports = ref.watch(
            getReportsbyIdProvider(member['id'] as int),
          );
          return reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load this member’s reports.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(
                    getReportsbyIdProvider(member['id'] as int),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (memberReports) {
          if (memberReports.isEmpty) {
            return const Center(child: Text('No reports submitted yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            itemCount: memberReports.length,
            itemBuilder: (context, index) {
              final report = memberReports[index];
              final reportingMonth = DateTime.parse(
                report['reporting_month'],
              );
              final submittedAt = DateTime.parse(report['submitted_at']);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  title: Text(
                    DateLabels.monthYear(reportingMonth),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Type: ${report['publisher_type']}\n'
                      'Hours: ${report['hours'] ?? 'N/A'} · '
                      'Bible studies: ${report['bible_studies'] ?? 'N/A'}\n'
                      'Participated: ${report['participated'] == null ? 'N/A' : report['participated'] == true ? 'Yes' : 'No'}\n'
                      'Submitted ${DateLabels.dateTime(submittedAt)}',
                    ),
                  ),
                  trailing: Text(
                    '${report['status']}',
                    textAlign: TextAlign.end,
                  ),
                ),
              );
            },
          );
        },
          );
        },
      ),
    );
  }
}


