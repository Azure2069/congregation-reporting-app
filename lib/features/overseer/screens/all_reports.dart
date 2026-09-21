import 'package:congregation_reporting/providers/group_provider.dart';
import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:congregation_reporting/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/group_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../core/utils/date_labels.dart';

class AllReports extends ConsumerWidget {
  const AllReports({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupMembers = ref.read(userProvider.notifier).getGroupMembers(1);
    return Scaffold(
      appBar: AppBar(title: const Text("All Group Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final member in groupMembers)
              Builder(
                builder: (context) {
                  final reports = ref
                      .read(reportProvider.notifier)
                      .getReportsForUser(member.userId);
                  return ExpansionTile(
                    title: Text(member.name),
                    children: [
                      DataTable(
                        columns: const [
                          DataColumn(label: Text("User ID")),
                          DataColumn(label: Text("Publisher Type")),
                          DataColumn(label: Text("Reporting Month")),
                          DataColumn(label: Text("Participated")),
                          DataColumn(label: Text("Bible Studies")),
                          DataColumn(label: Text("hours")),
                          DataColumn(label: Text("Submission Time")),
                          DataColumn(label: Text("Report Status")),
                        ],

                        rows: [
                          for (final report in reports)
                            DataRow(
                              cells: [
                                DataCell(Text(report.userId)),
                                DataCell(Text(report.publisherType)),
                                DataCell(
                                  Text(
                                    DateLabels.monthYear(report.reportingMonth),
                                  ),
                                ),
                                DataCell(Text("${report.participated}")),
                                DataCell(Text("${report.bibleStudies}")),
                                DataCell(Text("${report.hours}")),
                                DataCell(
                                  Text(DateLabels.dateTime(report.submittedAt)),
                                ),
                                DataCell(Text("${report.status}")),
                              ],
                            ),
                        ], //row
                      ),
                    ],
                  );
                },
              ),
          ], //children
        ),
      ),
    );
  }
}

/*
 final String userId;
  final String publisherType;
  final int? hours;
  final int? bibleStudies;
  final bool? participated;
  final DateTime reportingMonth;
  final DateTime submittedAt;
  final ReportStatus status;
  final DateTime originalSubmissionTime;

 */
