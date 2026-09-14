import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/report_provider.dart';

class ReportHistoryScreen extends ConsumerWidget {
  // final Report? report;
  const ReportHistoryScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportProvider);
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
          if (reports.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9EEE8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.folder_open_outlined,
                        color: Color(0xFF176B62),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No reports yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173B38),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your monthly submissions will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF647773), height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
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
                      title: Text(
                        "${months[report.reportingMonth.month - 1]} ${report.reportingMonth.year}",
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Publisher Type: ${report.publisherType}\n'
                          'Participated: ${report.participated}\n'
                          'Bible Studies: ${report.bibleStudies}'
                          '\nSubmission Time: ${report.submittedAt.day}/${report.submittedAt.month}/${report.submittedAt.year} ${report.submittedAt.hour}:${report.submittedAt.minute}',
                        ),
                      ),
                      trailing: const Chip(label: Text("Submitted")),
                    );
                  } else if (report.publisherType == 'Auxiliary Pioneer' ||
                      report.publisherType == 'Regular Pioneer') {
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
                          Icons.calendar_month,
                          color: Color(0xFF176B62),
                          size: 19,
                        ),
                      ),
                      title: Text(
                        "${months[report.reportingMonth.month - 1]} ${report.reportingMonth.year}",
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Publisher Type: ${report.publisherType}\n'
                          "Hours: ${report.hours}\nBible Studies: ${report.bibleStudies}"
                          '\nSubmission Time: ${report.submittedAt.day}/${report.submittedAt.month}/${report.submittedAt.year} ${report.submittedAt.hour}:${report.submittedAt.minute}',
                        ),
                      ),
                      trailing: const Chip(label: Text("Submitted")),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],

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
