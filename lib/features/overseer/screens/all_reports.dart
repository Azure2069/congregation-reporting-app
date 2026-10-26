import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/group/group_api.dart';
import '../../../core/api/reports/reports_api.dart';
import '../../../core/api/service_assignments/service_assignments_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';
import '../../../core/utils/date_labels.dart';
import '../services/report_export_service.dart';

class AllReports extends ConsumerStatefulWidget {
  const AllReports({super.key});

  @override
  ConsumerState<AllReports> createState() => _AllReportsState();
}

class _AllReportsState extends ConsumerState<AllReports> {
  int? _selectedGroupId;
  String? _selectedMonth;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(getUserRolesProvider);
    final roleRecords = roles.asData?.value;
    final roleNames = roleRecords is List
        ? roleRecords
              .whereType<Map>()
              .map((record) => record['role'])
              .whereType<String>()
              .toSet()
        : <String>{};
    final isSecretary = roleNames.contains('secretary');

    return Scaffold(
      appBar: AppBar(
        title: Text(isSecretary ? 'Secretary dashboard' : 'All reports'),
      ),
      body: roles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ReportsState(
          icon: Icons.lock_outline,
          title: 'Reports unavailable',
          message: 'Unable to verify your role. Please try again later.',
        ),
        data: (roleRecords) {
          final roleNames = roleRecords is List
              ? roleRecords
                    .whereType<Map>()
                    .map((record) => record['role'])
                    .whereType<String>()
                    .toSet()
              : <String>{};
          if (!roleNames.contains('elder')) {
            return const _ReportsState(
              icon: Icons.lock_outline,
              title: 'Access unavailable',
              message: 'You do not have access to all reports.',
            );
          }

          final reports = ref.watch(getAllReportsProvider);
          final users = ref.watch(viewUsersProvider);
          final groups = ref.watch(getGroupsProvider);
          final assignments = ref.watch(getAssignmentsProvider);
          return reports.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const _ReportsState(
              icon: Icons.cloud_off_outlined,
              title: 'Reports unavailable',
              message: 'Unable to load reports. Please try again later.',
            ),
            data: (reportRecords) => users.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => const _ReportsState(
                icon: Icons.people_outline,
                title: 'Members unavailable',
                message: 'Unable to load member details.',
              ),
              data: (userRecords) => groups.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => const _ReportsState(
                  icon: Icons.groups_outlined,
                  title: 'Groups unavailable',
                  message: 'Unable to load groups for report filtering.',
                ),
                data: (groupRecords) => assignments.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const _ReportsState(
                    icon: Icons.badge_outlined,
                    title: 'Service assignments unavailable',
                    message:
                        'Unable to load service types needed for monthly summaries.',
                  ),
                  data: (assignmentRecords) => _buildReportArchive(
                    reportRecords: reportRecords,
                    userRecords: userRecords,
                    groupRecords: groupRecords,
                    assignmentRecords: assignmentRecords,
                    isSecretary: roleNames.contains('secretary'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportArchive({
    required dynamic reportRecords,
    required dynamic userRecords,
    required dynamic groupRecords,
    required dynamic assignmentRecords,
    required bool isSecretary,
  }) {
    if (reportRecords is! List ||
        userRecords is! List ||
        groupRecords is! List ||
        assignmentRecords is! List) {
      return const _ReportsState(
        icon: Icons.cloud_off_outlined,
        title: 'Reports unavailable',
        message:
            'The reports, users, groups, or service assignments response could not be read.',
      );
    }

    final reports = reportRecords.whereType<Map>().toList();
    final users = userRecords.whereType<Map>().toList();
    final groups = groupRecords.whereType<Map>().toList();
    final usersById = <int, Map>{
      for (final user in users)
        if (user['id'] is int) user['id'] as int: user,
    };
    final groupsById = <int, Map>{
      for (final group in groups)
        if (group['id'] is int) group['id'] as int: group,
    };
    final assignmentsById = <int, Map>{
      for (final assignment in assignmentRecords.whereType<Map>())
        if (_intValue(assignment['id']) != null)
          _intValue(assignment['id'])!: assignment,
    };

    final monthKeys =
        reports.map(_monthKeyForReport).whereType<String>().toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    final groupFilteredReports = reports.where((report) {
      if (_selectedGroupId != null) {
        final userId = report['user_id'];
        final user = userId is int ? usersById[userId] : null;
        if (user?['group_id'] != _selectedGroupId) return false;
      }
      return true;
    }).toList();
    final monthlySummaries = _summarizeByMonth(
      groupFilteredReports,
      assignmentsById,
    );
    final filteredReports = groupFilteredReports.where((report) {
      return _selectedMonth == null ||
          _monthKeyForReport(report) == _selectedMonth;
    }).toList()..sort(_compareReportsNewestFirst);

    final exportRows = filteredReports
        .map(
          (report) =>
              _exportRow(report, usersById, groupsById, assignmentsById),
        )
        .toList();
    final approvedCount = filteredReports
        .where((report) => '${report['status']}'.toLowerCase() == 'approved')
        .length;

    return CustomScrollView(
      slivers: [
        if (isSecretary)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00695C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.assessment_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'SECRETARY DASHBOARD',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.78),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Monthly report archive',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroStat(
                          label: 'Reports',
                          value: '${filteredReports.length}',
                        ),
                        _HeroStat(label: 'Approved', value: '$approvedCount'),
                        _HeroStat(
                          label: 'Months',
                          value: '${monthlySummaries.length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (isSecretary)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find reports',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedGroupId ?? 0,
                          decoration: const InputDecoration(
                            labelText: 'Group',
                            prefixIcon: Icon(Icons.groups_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 0,
                              child: Text('All groups'),
                            ),
                            for (final entry in groupsById.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(
                                  entry.value['name']?.toString() ??
                                      'Group ${entry.key}',
                                ),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _selectedGroupId = value == null || value == 0
                                ? null
                                : value,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedMonth ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Reporting month',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('All months'),
                            ),
                            for (final key in monthKeys)
                              DropdownMenuItem(
                                value: key,
                                child: Text(_monthLabel(key)),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _selectedMonth =
                                value == null || value.isEmpty ? null : value,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (monthlySummaries.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Monthly summaries',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Publisher totals exclude auxiliary and regular pioneers.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      // Leave enough room for the three service categories
                      // and the month totals without clipping the card.
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: monthlySummaries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => _MonthlySummaryCard(
                          summary: monthlySummaries[index],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${filteredReports.length} ${filteredReports.length == 1 ? 'report' : 'reports'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isExporting || filteredReports.isEmpty
                            ? null
                            : () => _exportReports(
                                title: _exportTitle(groupsById),
                                fileName: _exportFileName(groupsById),
                                rows: exportRows,
                                format: ReportExportFormat.pdf,
                              ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('PDF'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _isExporting || filteredReports.isEmpty
                            ? null
                            : () => _exportReports(
                                title: _exportTitle(groupsById),
                                fileName: _exportFileName(groupsById),
                                rows: exportRows,
                                format: ReportExportFormat.word,
                              ),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Word'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (!isSecretary)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Report archive',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
        if (filteredReports.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _ReportsState(
              icon: Icons.inbox_outlined,
              title: 'No reports found',
              message: 'There are no reports for the selected filters.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final report = filteredReports[index];
                final row = exportRows[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.description_outlined),
                      ),
                      title: Text(row[1]),
                      subtitle: Text(
                        '${row[0]} · ${row[2]}\n'
                        'Type: ${row[3]} · Hours: ${row[4]} · '
                        'Bible studies: ${row[5]}\n'
                        'Submitted: ${row[7]}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        report['status']?.toString() ?? 'Unknown',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                );
              }, childCount: filteredReports.length),
            ),
          ),
      ],
    );
  }

  List<String> _exportRow(
    Map report,
    Map<int, Map> usersById,
    Map<int, Map> groupsById,
    Map<int, Map> assignmentsById,
  ) {
    final userId = report['user_id'];
    final user = userId is int ? usersById[userId] : null;
    final groupId = user?['group_id'];
    final group = groupId is int ? groupsById[groupId] : null;
    final reportingMonth = DateTime.tryParse(
      report['reporting_month']?.toString() ?? '',
    );
    final submittedAt = DateTime.tryParse(
      report['submitted_at']?.toString() ?? '',
    );
    final participated = report['participated'];

    return [
      group?['name']?.toString() ?? 'Unassigned',
      user?['name']?.toString() ?? 'Unknown member',
      reportingMonth == null ? 'Unknown' : DateLabels.monthYear(reportingMonth),
      _serviceTypeLabel(_serviceTypeForReport(report, assignmentsById)),
      report['hours']?.toString() ?? 'N/A',
      report['bible_studies']?.toString() ?? 'N/A',
      participated == null
          ? 'N/A'
          : participated == true
          ? 'Yes'
          : 'No',
      submittedAt == null ? 'Unknown' : DateLabels.dateTime(submittedAt),
      report['status']?.toString() ?? 'Unknown',
    ];
  }

  String _serviceTypeForReport(Map report, Map<int, Map> assignmentsById) {
    final assignmentId = _intValue(report['service_assignment_id']);
    final assignment = assignmentId == null
        ? null
        : assignmentsById[assignmentId];
    final rawType =
        assignment?['service_type'] ?? report['publisher_type'] ?? 'unknown';
    return rawType
        .toString()
        .toLowerCase()
        .split('.')
        .last
        .replaceAll(' ', '_');
  }

  List<_MonthlyReportSummary> _summarizeByMonth(
    List<Map> reports,
    Map<int, Map> assignmentsById,
  ) {
    final summaries = <String, _MonthlyReportSummary>{};
    for (final report in reports) {
      final monthKey = _monthKeyForReport(report);
      if (monthKey == null) continue;
      final summary = summaries.putIfAbsent(
        monthKey,
        () => _MonthlyReportSummary(monthKey),
      );
      summary.add(report, _serviceTypeForReport(report, assignmentsById));
    }
    return summaries.values.toList()
      ..sort((a, b) => b.monthKey.compareTo(a.monthKey));
  }

  String? _monthKeyForReport(Map report) {
    final date = DateTime.tryParse(report['reporting_month']?.toString() ?? '');
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

  String _monthLabel(String key) =>
      DateLabels.monthYear(DateTime.parse('$key-01'));

  int _compareReportsNewestFirst(Map a, Map b) {
    final aDate = DateTime.tryParse(a['reporting_month']?.toString() ?? '');
    final bDate = DateTime.tryParse(b['reporting_month']?.toString() ?? '');
    if (aDate == null) return bDate == null ? 0 : 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }

  String _exportTitle(Map<int, Map> groupsById) {
    final groupId = _selectedGroupId;
    final groupName = groupId == null
        ? null
        : groupsById[groupId]?['name']?.toString();
    final month = _selectedMonth == null ? null : _monthLabel(_selectedMonth!);
    return [
      if (groupName != null) groupName,
      if (month != null) month,
      'Service Reports',
    ].join(' - ');
  }

  String _exportFileName(Map<int, Map> groupsById) =>
      _exportTitle(groupsById).toLowerCase().replaceAll(' ', '_');

  Future<void> _exportReports({
    required String title,
    required String fileName,
    required List<List<String>> rows,
    required ReportExportFormat format,
  }) async {
    setState(() => _isExporting = true);
    try {
      await ReportExportService().export(
        title: title,
        fileName: fileName,
        rows: rows,
        format: format,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              format == ReportExportFormat.pdf
                  ? 'PDF export saved.'
                  : 'Word document saved.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to export reports.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _MonthlyReportSummary {
  _MonthlyReportSummary(this.monthKey);

  final String monthKey;
  int reportCount = 0;
  int publisherReports = 0;
  int publisherParticipated = 0;
  int publisherDidNotParticipate = 0;
  int publisherStudies = 0;
  int unclassifiedStudies = 0;
  int auxiliaryReports = 0;
  int auxiliaryHours = 0;
  int auxiliaryStudies = 0;
  int regularPioneerReports = 0;
  int regularPioneerHours = 0;
  int regularPioneerStudies = 0;
  int unclassifiedReports = 0;
  int approvedReports = 0;
  int returnedReports = 0;
  int submittedReports = 0;

  int get totalStudies =>
      publisherStudies +
      auxiliaryStudies +
      regularPioneerStudies +
      unclassifiedStudies;
  int get totalPioneerHours => auxiliaryHours + regularPioneerHours;

  void add(Map report, String serviceType) {
    reportCount++;
    switch ('${report['status'] ?? ''}'.toLowerCase().split('.').last) {
      case 'approved':
        approvedReports++;
        break;
      case 'returned':
        returnedReports++;
        break;
      case 'submitted':
      case 'in_review':
        submittedReports++;
        break;
    }
    switch (serviceType) {
      case 'publisher':
        publisherReports++;
        if (report['participated'] == true) {
          publisherParticipated++;
        } else if (report['participated'] == false) {
          publisherDidNotParticipate++;
        }
        publisherStudies += _intValue(report['bible_studies']) ?? 0;
        break;
      case 'auxiliary_pioneer':
        auxiliaryReports++;
        auxiliaryHours += _intValue(report['hours']) ?? 0;
        auxiliaryStudies += _intValue(report['bible_studies']) ?? 0;
        break;
      case 'regular_pioneer':
        regularPioneerReports++;
        regularPioneerHours += _intValue(report['hours']) ?? 0;
        regularPioneerStudies += _intValue(report['bible_studies']) ?? 0;
        break;
      default:
        unclassifiedReports++;
        unclassifiedStudies += _intValue(report['bible_studies']) ?? 0;
    }
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(.18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 12),
        ),
      ],
    ),
  );
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({required this.summary});

  final _MonthlyReportSummary summary;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 330,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateLabels.monthYear(DateTime.parse('${summary.monthKey}-01')),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF003C33),
              ),
            ),
            Text('${summary.reportCount} reports'),
            const Divider(height: 12),
            _SummaryMetric(
              label: 'Publishers (not pioneering)',
              value:
                  '${summary.publisherReports} reports · ${summary.publisherParticipated} participated / ${summary.publisherDidNotParticipate} did not · ${summary.publisherStudies} studies',
            ),
            _SummaryMetric(
              label: 'Auxiliary pioneers',
              value:
                  '${summary.auxiliaryReports} reports · ${summary.auxiliaryHours} hours · ${summary.auxiliaryStudies} studies',
            ),
            _SummaryMetric(
              label: 'Regular pioneers',
              value:
                  '${summary.regularPioneerReports} reports · ${summary.regularPioneerHours} hours · ${summary.regularPioneerStudies} studies',
            ),
            const SizedBox(height: 2),
            Text(
              'Approved ${summary.approvedReports} · Returned ${summary.returnedReports} · Submitted ${summary.submittedReports}',
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Total: ${summary.totalStudies} studies · ${summary.totalPioneerHours} pioneer hours'
              '${summary.unclassifiedReports == 0 ? '' : ' · ${summary.unclassifiedReports} unclassified'}',
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

int? _intValue(dynamic value) => value is int ? value : int.tryParse('$value');

String _serviceTypeLabel(String value) => switch (value) {
  'publisher' => 'Publisher (not pioneering)',
  'auxiliary_pioneer' => 'Auxiliary pioneer',
  'regular_pioneer' => 'Regular pioneer',
  _ => 'Unknown service type',
};

class _ReportsState extends StatelessWidget {
  const _ReportsState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF003C33)),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
