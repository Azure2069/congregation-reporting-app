import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/date_labels.dart';

class CurrentMonthReports extends ConsumerWidget {
  CurrentMonthReports({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = DateLabels.currentReportingMonth();
    final currentReports = ref
        .read(reportProvider.notifier)
        .getCurrentReports(currentMonth);
    return Scaffold(
      appBar: AppBar(title: const Text('Current reports')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateLabels.monthYear(currentMonth),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '${currentReports.length} report${currentReports.length == 1 ? '' : 's'} received',
              style: const TextStyle(color: Color(0xFF555555)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: currentReports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = currentReports[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEAF5FB),
                        child: Icon(
                          Icons.description_outlined,
                          color: Color(0xFF529FCB),
                        ),
                      ),
                      title: Text(
                        'Publisher ${report.userId}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${report.publisherType} · Submitted ${DateLabels.dateTime(report.submittedAt)}',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF211F54),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
