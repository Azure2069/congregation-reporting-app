import 'package:congregation_reporting/core/api/reports/reports_api.dart';
import 'package:congregation_reporting/core/api/users/users_api.dart';
import 'package:dio/dio.dart';
import '../../../core/api/user_role/user_role_api.dart';
import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/date_labels.dart';

class CurrentMonthReports extends ConsumerWidget {
  const CurrentMonthReports({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = DateLabels.currentReportingMonth();
    final currentMonthReports = ref.watch(getReportsByMonth(currentMonth));
    final userRoles = ref.watch(getUserRolesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Current reports')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5FB),
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
                      color: Color(0xFF211F54),
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
                                color: const Color(0xFF211F54),
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
            Expanded(
              child: currentMonthReports.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => const _ReportsState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Reports unavailable',
                  message:
                      'Unable to fetch reports right now. Please try again later.',
                ),
                data: (currentReports) {
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
                              loading: () => const LinearProgressIndicator(),
                              error: (error, stackTrace) => const _ReportsState(
                                icon: Icons.person_off_outlined,
                                title: 'Publisher unavailable',
                                message: 'Unable to load publisher details.',
                              ),
                              data: (currentUser) {
                                final rStatus = (report['status'] ?? 'Unknown')
                                    .toString();
                                final normalizedStatus = rStatus.toLowerCase();
                                return Column(
                                  children: [
                                    Card(
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.antiAlias,
                                      child: ExpansionTile(
                                        tilePadding: const EdgeInsets.symmetric(
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
                                            0xFFEAF5FB,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF211F54,
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
                                            title: const Text('Bible studies'),
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
                                                allRoles.add(roles[i]['role']);
                                              }
                                              if (allRoles.contains(
                                                "group_overseer",
                                              )) {
                                                if (normalizedStatus ==
                                                    'approved') {
                                                  return const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 12,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'This report is approved and can no longer be changed.',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFF287A4B,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                            context: context,
                                                            ref: ref,
                                                            reportId:
                                                                report['id'],
                                                            status: 'approved',
                                                            currentMonth:
                                                                currentMonth,
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Approve Report',
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
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
                                                                  currentMonth:
                                                                      currentMonth,
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
      ),
    );
  }
}

Future<void> _updateReportStatus({
  required BuildContext context,
  required WidgetRef ref,
  required dynamic reportId,
  required String status,
  required DateTime currentMonth,
}) async {
  try {
    await ref.read(reportsApiProvider).updateStatus(reportId, status);
    ref.invalidate(getReportsByMonth(currentMonth));
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
          Icon(icon, size: 44, color: const Color(0xFF529FCB)),
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
