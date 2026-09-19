import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/group_provider.dart';

/*class GroupMembersScreen extends ConsumerStatefulWidget {
  const GroupMembersScreen({super.key});

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}*/

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key});
  /*@override
  void initState() {
    super.initState();
    ref.read(userProvider.notifier).loadDummyUsers();
    ref.read(groupProvider.notifier).loadDummyGroups();
  }
  */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final groupMembers = ref.read(userProvider.notifier).getGroupMembers(1); 

    return Scaffold(
      appBar: AppBar(title: Text("Group Members")),
      body: ListView.builder(
        itemCount: groupMembers.length,
        itemBuilder: (BuildContext, int index) {


          return Card(

            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(title: Text("${groupMembers[index].name}"),
            subtitle: Text("${groupMembers[index].groupId}\n${groupMembers[index].roles}\n${groupMembers[index].serviceType}"),
            trailing: Text("${groupMembers[index].userId}"),
            onTap: () {
              context.push('/memberReport', extra: groupMembers[index]);
            },
            ),
            
          );
        },
      ),
    );
  }
}
