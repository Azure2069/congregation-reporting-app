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
      appBar: AppBar(title: const Text('Group members')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: groupMembers.length,
        itemBuilder: (BuildContext, int index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text("${groupMembers[index].name}"),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              subtitle: Text(
                "${groupMembers[index].roles} · ${groupMembers[index].serviceType}",
              ),
              leading: CircleAvatar(
                child: Text(groupMembers[index].name.substring(0, 1)),
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF211F54),
              ),
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
