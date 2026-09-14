import 'package:congregation_reporting/models/reports.dart';
import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;
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
                  colors: [Color(0xFF176B62), Color(0xFF1E8A80)],
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
                      color: Colors.white.withOpacity(0.18),
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
                          '${months[report.reportingMonth.month-1]} ${report.reportingMonth.year}', // Display the reporting month
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
                    child: const Text(
                      'Submitted',
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
                color: const Color(0xFF173B38),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Details of your monthly submission.',
              style: TextStyle(color: Color(0xFF647773)),
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
                        color: Color(0xFF173B38),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if(report.publisherType=='Publisher')...[_buildDetailRow('Service type', '${report.publisherType}'),
                    _buildDetailRow('Participated', '${report.participated==true?'Yes':'No'}'),
                    _buildDetailRow('Bible study', '${report.bibleStudies}  study(ies)'),
                    _buildDetailRow('Status', 'Submitted'),
                    _buildDetailRow('Submission time', '${report.submittedAt.day}/${report.submittedAt.month}/${report.submittedAt.year} ${report.submittedAt.hour}:${report.submittedAt.minute}'),
]
                      
         else if(report.publisherType=="Regular Pioneer"|| report.publisherType=="Auxiliary Pioneer")...[
          _buildDetailRow('Service type', '${report.publisherType}'),
                    _buildDetailRow('Bible study', '${report.bibleStudies}  study(ies)'),
                    _buildDetailRow('Hours', '${report.hours} hour(s)'),
                    _buildDetailRow('Status', 'Submitted'),
                    _buildDetailRow('Submission time', '${report.submittedAt.day}/${report.submittedAt.month}/${report.submittedAt.year} ${report.submittedAt.hour}:${report.submittedAt.minute}'),
           
         ]
                      
                    
                    
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
                color: Color(0xFF647773),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF173B38),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
