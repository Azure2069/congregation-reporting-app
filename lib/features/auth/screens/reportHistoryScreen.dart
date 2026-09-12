import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/report_data.dart';
import '../../../models/reports.dart';

class ReportHistoryScreen extends StatefulWidget {
  final Report? report;
  const ReportHistoryScreen({super.key, this.report});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreen();
}

class _ReportHistoryScreen extends State<ReportHistoryScreen> {

  static const months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
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
            child: ListView.builder(
              itemCount: reports.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final report = reports[index];
                if (report.publisherType == "Publisher") {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    onTap: () {
                      context.push('/report-details', extra: report);
                    },
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFD9EEE8),
                      child: Icon(
                        Icons.calendar_today,
                        color: Color(0xFF176B62),
                        size: 19,
                      ),
                    ),
                    title: Text("${months[report.reportingMonth.month-1]} ${report.reportingMonth.year}"),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Publisher Type: ${report.publisherType}\n'
                        'Participated: ${report.participated}\n'
                        'Bible Studies: ${report.bibleStudies}'
                        '\nSubmission Time: ${report.submittedAt}',
                      ),
                    ),
                    trailing: const Chip(label: Text("Submitted")),
                  );
                } else if (report.publisherType ==
                        'Auxiliary Pioneer' ||
                    report.publisherType == 'Regular Pioneer') {
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      onTap: () {
                        context.push('/report-details', extra: report);
                      },
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD9EEE8),
                        child: Icon(
                          Icons.calendar_month,
                          color: Color(0xFF176B62),
                          size: 19,
                        ),
                      ),
                      title: Text("${months[report.reportingMonth.month-1]} ${report.reportingMonth.year}"),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Publisher Type: ${report.publisherType}\n'
                          "Hours: ${report.hours}\nBible Studies: ${report.bibleStudies}"
                        '\nSubmission Time: ${report.submittedAt}'
                        ),
                      ),
                      trailing: const Chip(label: Text("Submitted")),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
