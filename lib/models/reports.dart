class Report {
  final String userId;
  final String publisherType;
  final int? hours;
  final int? bibleStudies;
  final bool? participated;
  final DateTime reportingMonth;
  final DateTime submittedAt;
  final ReportStatus status;
  final DateTime originalSubmissionTime;

  Report({
    required this.publisherType,
    required this.userId,
    this.hours,
    this.bibleStudies,
    this.participated,
    required this.reportingMonth,
    required this.submittedAt,
    required this.status,
    required this.originalSubmissionTime,
  });

  
}

enum ReportStatus { submitted, approved, returned }
