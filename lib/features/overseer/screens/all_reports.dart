import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:congregation_reporting/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_labels.dart';

class AllReports extends ConsumerWidget {
  const AllReports({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupMembers = ref.read(userProvider.notifier).getGroupMembers(1);
    return Scaffold(
      appBar: AppBar(title: const Text("All Group Reports")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Report archive',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          const Text(
            'Expand a member to review each monthly report.',
            style: TextStyle(color: Color(0xFF555555)),
          ),
          const SizedBox(height: 20),
          for (final member in groupMembers)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (context) {
                  final reports = ref
                      .read(reportProvider.notifier)
                      .getReportsForUser(member.userId);
                  return ExpansionTile(
                    title: Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${reports.length} report${reports.length == 1 ? '' : 's'}',
                    ),
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      if (reports.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Text(
                            'No reports submitted yet.',
                            style: TextStyle(color: Color(0xFF555555)),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DataTable(
                            columnSpacing: 26,
                            horizontalMargin: 8,
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
                                        DateLabels.monthYear(
                                          report.reportingMonth,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text("${report.participated}")),
                                    DataCell(Text("${report.bibleStudies}")),
                                    DataCell(Text("${report.hours}")),
                                    DataCell(
                                      Text(
                                        DateLabels.dateTime(report.submittedAt),
                                      ),
                                    ),
                                    DataCell(Text("${report.status}")),
                                  ],
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
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
