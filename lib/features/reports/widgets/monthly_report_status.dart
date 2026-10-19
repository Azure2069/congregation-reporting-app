import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/reports/reports_api.dart';
import '../../../core/utils/date_labels.dart';

class MonthlyReportStatus extends ConsumerWidget {
  final int userId;
  const MonthlyReportStatus({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(getReportsbyIdProvider(userId));
    final reportingMonth = DateLabels.currentReportingMonth();
    return reportAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => const Text("Unable to Load report status"),
      data: (reports) {
        final matchingReports = reports.where((report) {
          final date = DateTime.parse(report['reporting_month']);
          return date.year == reportingMonth.year &&
              date.month == reportingMonth.month;
        }).toList();
        if (matchingReports.isEmpty) {
          return const Text("Not Submitted");
        }
        final status = matchingReports.first['status'] as String;
        switch (status) {
          case 'submitted':
            return const Text('Submitted');

          case 'in_review':
            return const Text('In review');

          case 'approved':
            return const Text('Approved');

          case 'returned':
            return const Text('Returned');

          default:
            return Text(status);
          }
      },
    );
  }
}
