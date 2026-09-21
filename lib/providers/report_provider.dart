import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reports.dart';

class ReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() {
    return [
      Report(
        userId: "1", // Isaac
        publisherType: "Publisher",
        participated: true,
        bibleStudies: 3,
        hours: null,
        reportingMonth: DateTime(2026, 9),
        submittedAt: DateTime(2026, 9, 5),
        originalSubmissionTime: DateTime(2026, 9, 5),
        status: ReportStatus.submitted,
      ),

      Report(
        userId: "1", // Isaac
        publisherType: "Publisher",
        participated: true,
        bibleStudies: 4,
        hours: null,
        reportingMonth: DateTime(2026, 8),
        submittedAt: DateTime(2026, 8, 4),
        originalSubmissionTime: DateTime(2026, 8, 4),
        status: ReportStatus.approved,
      ),

      Report(
        userId: "2", // Collins
        publisherType: "Publisher",
        participated: true,
        bibleStudies: 2,
        hours: null,
        reportingMonth: DateTime(2026, 9),
        submittedAt: DateTime(2026, 9, 6),
        originalSubmissionTime: DateTime(2026, 9, 6),
        status: ReportStatus.approved,
      ),

      Report(
        userId: "3", // Henrietta
        publisherType: "Publisher",
        participated: false,
        bibleStudies: null,
        hours: null,
        reportingMonth: DateTime(2026, 9),
        submittedAt: DateTime(2026, 9, 7),
        originalSubmissionTime: DateTime(2026, 9, 7),
        status: ReportStatus.approved,
      ),

      Report(
        userId: "4", // Naomi - Regular Pioneer
        publisherType: "Regular Pioneer",
        participated: null,
        bibleStudies: 6,
        hours: 50,
        reportingMonth: DateTime(2026, 9),
        submittedAt: DateTime(2026, 9, 5),
        originalSubmissionTime: DateTime(2026, 9, 5),
        status: ReportStatus.submitted,
      ),

      Report(
        userId: "4", // Naomi
        publisherType: "Regular Pioneer",
        participated: null,
        bibleStudies: 5,
        hours: 48,
        reportingMonth: DateTime(2026, 8),
        submittedAt: DateTime(2026, 8, 6),
        originalSubmissionTime: DateTime(2026, 8, 6),
        status: ReportStatus.approved,
      ),

      Report(
        userId: "5", // Enoch
        publisherType: "Publisher",
        participated: true,
        bibleStudies: 2,
        hours: null,
        reportingMonth: DateTime(2026, 9),
        submittedAt: DateTime(2026, 9, 4),
        originalSubmissionTime: DateTime(2026, 9, 4),
        status: ReportStatus.approved,
      ),
    ];
  }

  bool isDuplicate(Report report) {
    return state.any(
      (existingReport) =>
          existingReport.reportingMonth.month == report.reportingMonth.month &&
          existingReport.reportingMonth.year == report.reportingMonth.year &&
          existingReport.userId == report.userId,
    );
  }

  bool canResubmit(Report old) {
    final difference = DateTime.now().difference(old.originalSubmissionTime);
    if (difference >= Duration.zero &&
        difference <= const Duration(hours: 24) &&
        old.status == ReportStatus.submitted) {
      return true;
    }
    return false;
  }

  List<Report> getCurrentReports(DateTime date) {
    return state.where((existingReport) {
      return (existingReport.reportingMonth.month == date.month &&
          existingReport.reportingMonth.year == date.year);
    }).toList();
  }

  bool updateReport(Report old, Report newReport) {
    if (canResubmit(old) && (state.contains(old))) {
      state = state.map((existingReport) {
        if (existingReport == old) {
          return Report(
            userId: old.userId,
            publisherType: newReport.publisherType,
            hours: newReport.hours,
            bibleStudies: newReport.bibleStudies,
            participated: newReport.participated,
            reportingMonth: old.reportingMonth,
            submittedAt: DateTime.now(),
            status: ReportStatus.submitted,
            originalSubmissionTime: old.originalSubmissionTime,
          );
        }
        return existingReport;
      }).toList();

      return true;
    }
    return false;
  }

  bool addReport(Report report) {
    if (!isDuplicate(report)) {
      state = [...state, report];
      return true;
    } else {
      return false;
    }
  }

  void removeReport(Report report) {
    state = state.where((existingReport) => existingReport != report).toList();
  }

  void updateStatus(Report report, ReportStatus newStatus) {
    state = state.map((existingReport) {
      if (report == existingReport) {
        return Report(
          userId: existingReport.userId,
          publisherType: existingReport.publisherType,
          participated: existingReport.participated,
          reportingMonth: existingReport.reportingMonth,
          bibleStudies: existingReport.bibleStudies,
          submittedAt: existingReport.submittedAt,
          hours: existingReport.hours,
          originalSubmissionTime: existingReport.originalSubmissionTime,
          status: newStatus,
        );
      }
      return existingReport;
    }).toList();
  }

  void clearReports() {
    state = [];
  }

  List<Report> getReportsForUser(String userId) {
    return state.where((existingReport) {
      return existingReport.userId == userId;
    }).toList();
  }
}

final reportProvider = NotifierProvider<ReportNotifier, List<Report>>(
  ReportNotifier.new,
);
