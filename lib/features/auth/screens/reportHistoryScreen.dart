import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/report_provider.dart';
import '../../../models/reports.dart';

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
      appBar: AppBar(
        title: const Text("Report History"),
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Monthly reports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF222121),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review your submitted ministry activity.',
            style: TextStyle(color: Color(0xFF555555)),
          ),
          const SizedBox(height: 22),
          if (reports.isEmpty)
            _buildEmptyState()
          else
            ...reports.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReportCard(context, report),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: Color(0xFF529FCB),
            ),
            const SizedBox(height: 16),
            const Text(
              'No reports yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your monthly submissions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
    final isPublisher = report.publisherType == 'Publisher';
    final month =
        '${months[report.reportingMonth.month - 1]} ${report.reportingMonth.year}';
    final status =
        report.status.name[0].toUpperCase() + report.status.name.substring(1);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/report-details', extra: report),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPublisher
                          ? Icons.person_outline
                          : Icons.workspace_premium_outlined,
                      color: const Color(0xFF529FCB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          month,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222121),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          report.publisherType,
                          style: const TextStyle(color: Color(0xFF555555)),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(status),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: isPublisher
                    ? [
                        _metric(
                          'Participated',
                          report.participated == true ? 'Yes' : 'No',
                        ),
                        _metric('Bible studies', '${report.bibleStudies ?? 0}'),
                      ]
                    : [
                        _metric('Hours', '${report.hours ?? 0}'),
                        _metric('Bible studies', '${report.bibleStudies ?? 0}'),
                      ],
              ),
              const SizedBox(height: 14),
              Text(
                'Submitted ${report.submittedAt.day}/${report.submittedAt.month}/${report.submittedAt.year}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF211F54),
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF222121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
