import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:congregation_reporting/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user.dart';
import '../../../core/utils/date_labels.dart';

class MemberReportsScreen extends ConsumerWidget {
  final User member;
  const MemberReportsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final currentMember = ref.read(userProvider)[1];
    final reports = ref
        .watch(reportProvider.notifier)
        .getReportsForUser(member.userId);
    return Scaffold(
      appBar: AppBar(title: Text('Reports for ${member.name}')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: reports.length,
        itemBuilder: (BuildContext context, int index) {
          final report = reports[index];
          return Card(
            borderOnForeground: true,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              title: Text(
                DateLabels.monthYear(report.reportingMonth),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Hours: ${report.hours ?? 0} · Bible studies: ${report.bibleStudies ?? 0}\nSubmitted ${DateLabels.dateTime(report.submittedAt)}',
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF211F54),
              ),
            ),
          );
        },
      ),
    );
  }
}
