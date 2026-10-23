import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:congregation_reporting/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/api/reports/reports_api.dart';
import '../../../core/api/group/group_api.dart';
import '../../../core/api/congregation/congregation_api.dart';
import '../../../core/api/users/users_api.dart';

class AllReports extends ConsumerWidget {
  const AllReports({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(getAllReportsProvider);
    final groupMembers = ref.watch(getGroupMembersProvider);
    final congregation = ref.watch(getMyCongregationProvider);

    return Scaffold(
      appBar: AppBar(
        title: congregation.when(
          loading: () => LinearProgressIndicator(),
          error: (error, stackTrace) => const Text("Unable to fetch Congregation"),
          data: (congregation) {
            return Text('${congregation['name']}');
          },
        ),
      ),
      body: reports.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, stackTrace) => const Text("Unable to load reports"),
        data: (reports) {
          final allPublishers = ref.watch(viewUsersProvider);
          return allPublishers.when(
            loading: () => LinearProgressIndicator(),
            error: (error, stackTrace) => const Text("Unable to load users"),
            data: (users) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Text(
                    'Report archive',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Expand a member to review each monthly report.',
                    style: TextStyle(color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 20),
                  for (final member in users)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: Builder(
                        builder: (context) {
                          final individualReports = ref.watch(
                            getReportsbyIdProvider(member['id']),
                          );

                          return 
                          individualReports.when(
                            loading: ()=> const LinearProgressIndicator(),
                            error: (error, stackTrace) => const Text("Error Loading repo"),
                            
                            data: (userReports){

                            return ExpansionTile(
                            title: Text(
                              member['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${userReports.length} report${userReports.length == 1 ? '' : 's'}',
                            ),
                            childrenPadding: const EdgeInsets.only(bottom: 12),
                            children: [
                              if (userReports.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    'No reports submitted yet.',
                                    style: TextStyle(color: Color(0xFF555555)),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: DataTable(
                                    columnSpacing: 26,
                                    horizontalMargin: 8,
                                    columns: const [
                                      DataColumn(label: Text("User ID")),
                                      //DataColumn(label: Text("Publisher Type")),
                                      DataColumn(
                                        label: Text("Reporting Month"),
                                      ),
                                      DataColumn(label: Text("Participated")),
                                      DataColumn(label: Text("Bible Studies")),
                                      DataColumn(label: Text("hours")),
                                      DataColumn(
                                        label: Text("Submission Time"),
                                      ),
                                      DataColumn(label: Text("Report Status")),
                                    ],

                                    rows: [
                                      for (final report in userReports)
                                        DataRow(
                                          cells: [
                                            DataCell(Text('${report['user_id']}')),
                                            //DataCell(
                                              //Text(report['publisher_type']),
                                            //),
                                            DataCell(
                                              Text(
                                                DateLabels.monthYear(
                                                  DateTime.parse(report['reporting_month']),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text("${report['participated']}"),
                                            ),
                                            DataCell(
                                              Text("${report['bible_studies']}"),
                                            ),
                                            DataCell(Text("${report['hours']}")),
                                            DataCell(
                                              Text(
                                                DateLabels.dateTime(
                                                  DateTime.parse(report['submitted_at']),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text("${report['status']}")),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                            
                            }
                            );
                          
                          
                        },
                      ),
                    ),
                ],
              );
            },
          );
          ;
        },
      ),
    );
  }
}

/*
 final String userId;
  final String publisherType;
  final int? hours;
  final int? bibleStudies;
  final bool? participated;
  final DateTime reportingMonth;
  final DateTime submittedAt;
  final ReportStatus status;
  final DateTime originalSubmissionTime;

 */
