import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reports.dart';

class ReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() {
    return [];
  }

    void addReport(Report report) {
    state = [...state, report];
  }
}

final reportProvider = NotifierProvider<ReportNotifier, List<Report>>(
  ReportNotifier.new,
);
