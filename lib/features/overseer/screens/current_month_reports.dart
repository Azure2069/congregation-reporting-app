import 'package:congregation_reporting/core/api/reports/reports_api.dart';
import 'package:congregation_reporting/core/api/users/users_api.dart';
import 'package:congregation_reporting/core/api/group/group_api.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/user_role/user_role_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/date_labels.dart';

class CurrentMonthReports extends ConsumerWidget {
  const CurrentMonthReports({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = DateLabels.currentReportingMonth();
    final userRoles = ref.watch(getUserRolesProvider);
    final currentUser = ref.watch(getcurrentUserProvider);
    final currentUserRecord = currentUser.asData?.value;
    final assignedGroupId = currentUserRecord is Map
        ? _userId(currentUserRecord['group_id'])
        : null;
    return Scaffold(
      appBar: AppBar(
        title: currentUser.when(
          loading: () => const Text('Group reports'),
          error: (error, stackTrace) => const Text('Group reports'),
          data: (user) {
            final groupId = _userId(user['group_id']);
            if (groupId == null) return const Text('Group reports');
            final group = ref.watch(getGroupByIdProvider(groupId));
            return group.when(
              loading: () => const Text('Group reports'),
              error: (error, stackTrace) => const Text('Group reports'),
              data: (record) => Text(
                record is Map && record['name'] is String
                    ? '${record['name']} reports'
                    : 'Group reports',
              ),
            );
          },
        ),
      ),
      body: userRoles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _ReportsState(
          icon: Icons.lock_outline,
          title: 'Reports unavailable',
          message: 'Unable to verify your role. Please try again later.',
        ),
        data: (roles) {
          final roleNames = roles is List
              ? roles
                    .whereType<Map>()
                    .map((record) => record['role'])
                    .whereType<String>()
                    .toSet()
              : <String>{};
          final canViewReports =
              roleNames.contains('elder') &&
              roleNames.contains('group_overseer');
          if (!canViewReports) {
            return const _ReportsState(
              icon: Icons.lock_outline,
              title: 'Access unavailable',
              message: 'You do not have access to group reports.',
            );
          }

          final currentMonthReports = ref.watch(getGroupReportsProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDFCE9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF003C33),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reporting period',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF555555),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              DateLabels.monthYear(currentMonth),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: const Color(0xFF003C33),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 188,
                  child: _AssignedGroupPublishers(
                    groupId: assignedGroupId,
                    reportingMonth: currentMonth,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: currentMonthReports.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const _ReportsState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Reports unavailable',
                      message:
                          'Unable to fetch reports right now. Please try again later.',
                    ),
                    data: (groupReports) {
                      if (groupReports is! List) {
                        return const _ReportsState(
                          icon: Icons.cloud_off_outlined,
                          title: 'Reports unavailable',
                          message:
                              'The group reports response could not be read.',
                        );
                      }
                      final currentReports = groupReports.where((report) {
                        if (report is! Map ||
                            report['reporting_month'] == null) {
                          return false;
                        }
                        final reportMonth = DateTime.tryParse(
                          report['reporting_month'].toString(),
                        );
                        return reportMonth != null &&
                            reportMonth.year == currentMonth.year &&
                            reportMonth.month == currentMonth.month;
                      }).toList();
                      if (currentReports.isEmpty) {
                        return const _ReportsState(
                          icon: Icons.inbox_outlined,
                          title: 'No reports yet',
                          message:
                              'Reports for this month will appear here when they are submitted.',
                        );
                      }
                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                '${currentReports.length} report${currentReports.length == 1 ? '' : 's'} received',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: currentReports.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final report = currentReports[index];
                                final user = ref.watch(
                                  getUserByIdProvider(report['user_id']),
                                );

                                return user.when(
                                  loading: () =>
                                      const LinearProgressIndicator(),
                                  error: (error, stackTrace) =>
                                      const _ReportsState(
                                        icon: Icons.person_off_outlined,
                                        title: 'Publisher unavailable',
                                        message:
                                            'Unable to load publisher details.',
                                      ),
                                  data: (currentUser) {
                                    final rStatus =
                                        (report['status'] ?? 'Unknown')
                                            .toString();
                                    final normalizedStatus = rStatus
                                        .toLowerCase();
                                    return Column(
                                      children: [
                                        Card(
                                          margin: EdgeInsets.zero,
                                          clipBehavior: Clip.antiAlias,
                                          child: ExpansionTile(
                                            tilePadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 6,
                                                ),
                                            childrenPadding:
                                                const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  16,
                                                ),
                                            leading: CircleAvatar(
                                              backgroundColor: const Color(
                                                0xFFEDFCE9,
                                              ),
                                              foregroundColor: const Color(
                                                0xFF003C33,
                                              ),
                                              child: Icon(Icons.person),
                                            ),
                                            title: Text(
                                              '${currentUser['name']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Submitted ${DateLabels.dateTime(DateTime.parse(report['submitted_at']))}',
                                                  ),
                                                  const SizedBox(height: 7),
                                                  _StatusBadge(status: rStatus),
                                                ],
                                              ),
                                            ),
                                            children: [
                                              const Divider(),

                                              ListTile(
                                                title: const Text(
                                                  'Reporting month',
                                                ),
                                                subtitle: Text(
                                                  DateLabels.monthYear(
                                                    DateTime.parse(
                                                      report['reporting_month'],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              ListTile(
                                                title: const Text(
                                                  'Bible studies',
                                                ),
                                                subtitle: Text(
                                                  '${report['bible_studies'] ?? 'N/A'}',
                                                ),
                                              ),

                                              ListTile(
                                                title: const Text('Hours'),
                                                subtitle: Text(
                                                  '${report['hours'] ?? 'N/A'}',
                                                ),
                                              ),

                                              ListTile(
                                                title: const Text('Status'),
                                                subtitle: Text('$rStatus'),
                                              ),

                                              userRoles.when(
                                                loading: () =>
                                                    CircularProgressIndicator(),
                                                error: (error, stackTrace) =>
                                                    const Text(
                                                      "Unable to load role",
                                                    ),
                                                data: (roles) {
                                                  final allRoles = [];
                                                  for (
                                                    int i = 0;
                                                    i < roles.length;
                                                    i++
                                                  ) {
                                                    allRoles.add(
                                                      roles[i]['role'],
                                                    );
                                                  }
                                                  if (allRoles.contains(
                                                    "group_overseer",
                                                  )) {
                                                    if (normalizedStatus ==
                                                        'approved') {
                                                      return const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 12,
                                                            ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'This report is approved and can no longer be changed.',
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFF287A4B,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () async {
                                                              await _updateReportStatus(
                                                                context:
                                                                    context,
                                                                ref: ref,
                                                                reportId:
                                                                    report['id'],
                                                                status:
                                                                    'approved',
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Approve Report',
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: OutlinedButton(
                                                            onPressed:
                                                                normalizedStatus ==
                                                                    'returned'
                                                                ? null
                                                                : () async {
                                                                    await _updateReportStatus(
                                                                      context:
                                                                          context,
                                                                      ref: ref,
                                                                      reportId:
                                                                          report['id'],
                                                                      status:
                                                                          'returned',
                                                                    );
                                                                  },
                                                            child: Text(
                                                              normalizedStatus ==
                                                                      'returned'
                                                                  ? 'Returned'
                                                                  : 'Return',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  return SizedBox(height: 1);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssignedGroupPublishers extends ConsumerWidget {
  const _AssignedGroupPublishers({
    required this.groupId,
    required this.reportingMonth,
  });

  final int? groupId;
  final DateTime reportingMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (groupId == null) {
      return const _ReportsState(
        icon: Icons.groups_outlined,
        title: 'Group unavailable',
        message: 'Your account is not assigned to a group.',
      );
    }

    final usersAsync = ref.watch(viewUsersProvider);
    final reportsAsync = ref.watch(getGroupReportsProvider);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Unable to load publishers in your group.'),
        ),
        data: (usersResponse) {
          if (usersResponse is! List) {
            return const Center(child: Text('Publisher list unavailable.'));
          }
          final publishers =
              usersResponse.whereType<Map>().where((user) {
                return _userId(user['group_id']) == groupId;
              }).toList()..sort(
                (a, b) => '${a['name'] ?? ''}'.toLowerCase().compareTo(
                  '${b['name'] ?? ''}'.toLowerCase(),
                ),
              );
          return reportsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                _publisherList(context, publishers, const <int, Map>{}),
            data: (reportResponse) {
              final monthReports = reportResponse is List
                  ? reportResponse.whereType<Map>().where((report) {
                      final month = DateTime.tryParse(
                        '${report['reporting_month'] ?? ''}',
                      );
                      return month != null &&
                          month.year == reportingMonth.year &&
                          month.month == reportingMonth.month;
                    })
                  : const <Map>[];
              final reportsByUser = <int, Map>{
                for (final report in monthReports)
                  if (_userId(report['user_id']) != null)
                    _userId(report['user_id'])!: report,
              };
              return _publisherList(context, publishers, reportsByUser);
            },
          );
        },
      ),
    );
  }

  Widget _publisherList(
    BuildContext context,
    List<Map> publishers,
    Map<int, Map> reportsByUser,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Your publishers · ${publishers.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF003C33),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: publishers.isEmpty
              ? const Center(
                  child: Text('No publishers are assigned to this group.'),
                )
              : ListView.separated(
                  itemCount: publishers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final publisher = publishers[index];
                    final id = _userId(publisher['id']);
                    final report = id == null ? null : reportsByUser[id];
                    final status = report?['status']?.toString() ?? 'No report';
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline),
                      title: Text(
                        '${publisher['name'] ?? 'Unnamed publisher'}',
                      ),
                      subtitle: Text('${publisher['username'] ?? ''}'),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          color: status.toLowerCase() == 'approved'
                              ? const Color(0xFF287A4B)
                              : status.toLowerCase() == 'returned'
                              ? const Color(0xFFB04431)
                              : const Color(0xFF616161),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: id == null
                          ? null
                          : () =>
                                context.push('/memberReport', extra: publisher),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

int? _userId(dynamic value) => value is int ? value : int.tryParse('$value');

Future<void> _updateReportStatus({
  required BuildContext context,
  required WidgetRef ref,
  required dynamic reportId,
  required String status,
}) async {
  try {
    await ref.read(reportsApiProvider).updateStatus(reportId, status);
    ref.invalidate(getGroupReportsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved' ? 'Report approved.' : 'Report returned.',
          ),
        ),
      );
    }
  } catch (error) {
    final message =
        error is DioException &&
            error.response?.data is Map &&
            error.response?.data['detail'] != null
        ? error.response!.data['detail'].toString()
        : 'Unable to update report. Please try again.';
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = status.trim().isEmpty ? 'Unknown' : status.trim();
    final normalized = label.toLowerCase();
    final isApproved = normalized == 'approved';
    final isReturned = normalized == 'returned';
    final color = isApproved
        ? const Color(0xFF287A4B)
        : isReturned
        ? const Color(0xFF9A4D26)
        : const Color(0xFF6C5A16);
    final background = isApproved
        ? const Color(0xFFE8F5EC)
        : isReturned
        ? const Color(0xFFFFF0E7)
        : const Color(0xFFFFF7D9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

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
          Icon(icon, size: 44, color: const Color(0xFF003C33)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}
