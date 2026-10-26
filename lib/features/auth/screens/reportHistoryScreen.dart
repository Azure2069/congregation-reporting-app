import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/api/reports/reports_api.dart';

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
    final reports = ref.watch(getMyReportsProvider);
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
          reports.when(
            loading: () => LinearProgressIndicator(),
            error: (error, stackTrace) => Text("Unable to load reports"),
            data: (allReports) {
              if (allReports.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildReportsCard(context, allReports);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: Color(0xFF003C33),
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
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/submitReport'),
              icon: const Icon(Icons.add),
              label: const Text('Submit this month’s report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsCard(BuildContext context, List reports) {
    return Column(
      children: reports.map((report) {
        final publisherType = (report['publisher_type'] ?? '').toString();
        final normalizedPublisherType = publisherType.toLowerCase().replaceAll(
          ' ',
          '_',
        );
        final isPublisher = normalizedPublisherType == 'publisher';
        final serviceTypeLabel = switch (normalizedPublisherType) {
          'publisher' => 'Publisher',
          'auxiliary_pioneer' => 'Auxiliary Pioneer',
          'regular_pioneer' => 'Regular Pioneer',
          _ when normalizedPublisherType.isEmpty => 'Unknown service type',
          _ =>
            normalizedPublisherType
                .replaceAll('_', ' ')
                .split(' ')
                .map(
                  (word) => word.isEmpty
                      ? word
                      : '${word[0].toUpperCase()}${word.substring(1)}',
                )
                .join(' '),
        };
        //final month = DateLabels.monthYear(report['reporting_month']);
        final month = DateLabels.monthYear(
          DateTime.parse(report['reporting_month']),
        );
        final rawStatus = report['status'] as String;

        final status = rawStatus.isEmpty
            ? rawStatus
            : '${rawStatus[0].toUpperCase()}${rawStatus.substring(1)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
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
                            color: const Color(0xFFEDFCE9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPublisher
                                ? Icons.person_outline
                                : Icons.workspace_premium_outlined,
                            color: const Color(0xFF003C33),
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
                                serviceTypeLabel,
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                ),
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
                                report['participated'] == true ? 'Yes' : 'No',
                              ),
                              _metric(
                                'Bible studies',
                                '${report['bible_studies'] ?? 0}',
                              ),
                            ]
                          : [
                              _metric('Hours', '${report['hours'] ?? 0}'),
                              _metric(
                                'Bible studies',
                                '${report['bible_studies'] ?? 0}',
                              ),
                            ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Submitted ${DateLabels.shortDate(DateTime.parse(report['submitted_at']))}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();
    final background = normalized == 'approved'
        ? const Color(0xFFEDFCE9)
        : normalized == 'returned'
        ? const Color(0xFFFFF0ED)
        : normalized == 'submitted'
        ? const Color(0xFFF1F5FF)
        : const Color(0xFFEEECE7);
    final foreground = normalized == 'approved'
        ? const Color(0xFF003C33)
        : normalized == 'returned'
        ? const Color(0xFFB04431)
        : normalized == 'submitted'
        ? const Color(0xFF1863DC)
        : const Color(0xFF616161);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),
        borderRadius: BorderRadius.circular(12),
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
