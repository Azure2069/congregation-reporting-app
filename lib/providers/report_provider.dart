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
          existingReport.reportingMonth.year == report.reportingMonth.year,
    );
  }

  bool submission_24_hours(Report old, Report newReport) {
    final difference = newReport.submittedAt.difference(old.submittedAt);
    return difference.inHours < 24;
  }

  void updateReport(Report old, Report newReport) {
    if (submission_24_hours(old, newReport)) {

        removeReport(old);
        addReport(newReport);
      }
    
  }

  bool addReport(Report report) {
    if (!isDuplicate(report)) {
      state = [...state, report];
      return true;
    } else
      return false;
  }

  void removeReport(Report report) {
    state = state.where((existingReport) => existingReport != report).toList();
  }

  void clearReports() {
    state = [];
  }
}

final reportProvider = NotifierProvider<ReportNotifier, List<Report>>(
  ReportNotifier.new,
);
