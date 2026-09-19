import 'package:congregation_reporting/providers/report_provider.dart';
import 'package:congregation_reporting/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user.dart';

class MemberReportsScreen extends ConsumerWidget {
  final User member;
  const MemberReportsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final currentMember = ref.read(userProvider)[1];
    final reports = ref
        .watch(reportProvider.notifier)
        .getReportsForUser(member.userId);
    return Scaffold(
      appBar: AppBar(title: Text('Reports for ${member.name}')),
      body: ListView.builder(
          itemCount: reports.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(borderOnForeground: true,
            child:ListTile(
              title: Text('Report for ${reports[index].reportingMonth.month}/${reports[index].reportingMonth.year}'),
              subtitle: Text('Hours: ${reports[index].hours}, Bible Studies: ${reports[index].bibleStudies}, Status: ${reports[index].status}'),
              trailing: Icon(Icons.arrow_forward),
            )
            );
          },
        ),
      
    );
  }
}
