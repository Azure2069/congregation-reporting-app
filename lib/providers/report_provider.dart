import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reports.dart';

class ReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() {
    return [];
  }

  bool isDuplicate(Report report) {
    return state.any(
      (existingReport) =>
          existingReport.reportingMonth.month == report.reportingMonth.month &&
          existingReport.reportingMonth.year == report.reportingMonth.year
          && existingReport.userId == report.userId,
    );
  }

  bool canResubmit(Report old) {
   
      final difference = DateTime.now().difference(old.originalSubmissionTime);
    if(difference<= const Duration(hours: 24) && old.status==ReportStatus.submitted){
      return true;
    }
    return false;
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
    return  existingReport.userId == userId;
    }).toList();
  }

}

final reportProvider = NotifierProvider<ReportNotifier, List<Report>>(
  ReportNotifier.new,
);


