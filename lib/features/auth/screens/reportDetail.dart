import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_labels.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map report;
  const ReportDetailScreen({super.key, required this.report});

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
    final publisherType = (report['publisher_type'] ?? '').toString();
    final normalizedPublisherType = publisherType.toLowerCase();
    final status = (report['status'] ?? 'unknown').toString();
    final reportingMonth = DateTime.parse(report['reporting_month'].toString());
    final submittedAt = DateTime.parse(report['submitted_at'].toString());
    final originalSubmissionValue = report['original_submission_time'];
    final originalSubmissionTime = originalSubmissionValue == null
        ? null
        : DateTime.tryParse(originalSubmissionValue.toString());
    final normalizedStatus = status.toLowerCase();
    final elapsedSinceOriginal = originalSubmissionTime == null
        ? null
        : DateTime.now().difference(originalSubmissionTime);
    final canUpdate =
        normalizedStatus == 'returned' ||
        (normalizedStatus == 'submitted' &&
            elapsedSinceOriginal != null &&
            elapsedSinceOriginal >= Duration.zero &&
            elapsedSinceOriginal <= const Duration(hours: 24));

    final displayPublisherType = publisherType
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');

    return Scaffold(
      appBar: AppBar(title: const Text('Report detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF003C33), Color(0xFF071829)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0x1FFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly report',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE9F5F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateLabels.monthYear(reportingMonth),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status.isEmpty
                          ? 'Unknown'
                          : '${status[0].toUpperCase()}${status.substring(1)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Report details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF222121),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Details of your monthly submission.',
              style: TextStyle(color: Color(0xFF616161)),
            ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submission overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222121),
                      ),
                    ),

                    const SizedBox(height: 18),
                    _buildDetailRow('Service type', displayPublisherType),
                    if (normalizedPublisherType == 'publisher') ...[
                      _buildDetailRow(
                        'Participated',
                        report['participated'] == null
                            ? 'N/A'
                            : report['participated'] == true
                            ? 'Yes'
                            : 'No',
                      ),
                      _buildDetailRow(
                        'Bible studies',
                        '${report['bible_studies'] ?? 0}',
                      ),
                    ] else if (normalizedPublisherType == 'regular_pioneer' ||
                        normalizedPublisherType == 'auxiliary_pioneer') ...[
                      _buildDetailRow(
                        'Bible studies',
                        '${report['bible_studies'] ?? 0}',
                      ),
                      _buildDetailRow('Hours', '${report['hours'] ?? 0}'),
                    ],
                    _buildDetailRow('Status', status),
                    _buildDetailRow(
                      'Submission time',
                      DateLabels.dateTime(submittedAt),
                    ),
                    if (canUpdate) ...[
                      const SizedBox(height: 12),
                      if (normalizedStatus == 'returned')
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'This report was returned. Update it and resubmit for review.',
                            style: TextStyle(color: Color(0xFFB04431)),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/updateReport', extra: report);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(
                            normalizedStatus == 'returned'
                                ? 'Update and resubmit'
                                : 'Update report',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF222121),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
