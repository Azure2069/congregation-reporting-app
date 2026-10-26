import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/service_assignments/service_assignments_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';

class ServiceAssignmentManagementScreen extends ConsumerStatefulWidget {
  const ServiceAssignmentManagementScreen({super.key});

  @override
  ConsumerState<ServiceAssignmentManagementScreen> createState() =>
      _ServiceAssignmentManagementScreenState();
}

class _ServiceAssignmentManagementScreenState
    extends ConsumerState<ServiceAssignmentManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(getAssignmentsProvider);
    final usersAsync = ref.watch(viewUsersProvider);
    final rolesAsync = ref.watch(getUserRolesProvider);
    final roles = rolesAsync.asData?.value;
    final canCreate =
        roles is List &&
        roles.whereType<Map>().any((row) => row['role'] == 'service_overseer');

    return Scaffold(
      appBar: AppBar(title: const Text('Service assignments')),
      body: assignmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _LoadError(
          message: _errorMessage(error),
          onRetry: () => ref.invalidate(getAssignmentsProvider),
        ),
        data: (assignmentResponse) => usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _LoadError(
            message: _errorMessage(error),
            onRetry: () => ref.invalidate(viewUsersProvider),
          ),
          data: (userResponse) {
            final users = userResponse is List
                ? userResponse.whereType<Map>().toList()
                : <Map>[];
            final assignments = assignmentResponse is List
                ? assignmentResponse.whereType<Map>().toList()
                : <Map>[];
            final filtered =
                users.where((user) {
                  final name = '${user['name'] ?? ''}'.toLowerCase();
                  final username = '${user['username'] ?? ''}'.toLowerCase();
                  return name.contains(_query) || username.contains(_query);
                }).toList()..sort(
                  (a, b) => '${a['name'] ?? ''}'.toLowerCase().compareTo(
                    '${b['name'] ?? ''}'.toLowerCase(),
                  ),
                );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Service history by member',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Review each member’s service periods. Service overseers can add assignments.',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _query = value.trim().toLowerCase()),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Find a member',
                          hintText: 'Search by name or username',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F7F4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Color(0xFF003C33),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Publisher and pioneer periods are shown below. The server prevents overlapping pioneer periods.',
                                style: TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No members match that search.'),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Future.wait([
                              ref.refresh(getAssignmentsProvider.future),
                              ref.refresh(viewUsersProvider.future),
                            ]);
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final member = filtered[index];
                              final memberId = _id(member['id']);
                              final memberAssignments =
                                  assignments
                                      .where(
                                        (assignment) =>
                                            _id(assignment['user_id']) ==
                                            memberId,
                                      )
                                      .toList()
                                    ..sort(
                                      (a, b) => _dateValue(
                                        b['start_date'],
                                      ).compareTo(_dateValue(a['start_date'])),
                                    );
                              return Card(
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFEDFCE9),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF003C33),
                                    ),
                                  ),
                                  title: Text(
                                    '${member['name'] ?? 'Unnamed member'}',
                                  ),
                                  subtitle: Text(
                                    '${member['group_id'] == null ? '' : 'Group ${member['group_id']} · '}'
                                    '${memberAssignments.length} assignment${memberAssignments.length == 1 ? '' : 's'}',
                                  ),
                                  trailing: canCreate && memberId != null
                                      ? IconButton(
                                          tooltip: 'Add assignment',
                                          onPressed: () =>
                                              _createAssignment(member),
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                        )
                                      : null,
                                  children: memberAssignments.isEmpty
                                      ? [
                                          const ListTile(
                                            title: Text(
                                              'No service assignments recorded.',
                                            ),
                                          ),
                                        ]
                                      : memberAssignments.map((assignment) {
                                          final endDate =
                                              assignment['end_date'];
                                          final range =
                                              '${_formatDate(assignment['start_date'])} – '
                                              '${endDate == null ? 'Ongoing' : _formatDate(endDate)}';
                                          return ListTile(
                                            dense: true,
                                            leading: const Icon(
                                              Icons.event_note_outlined,
                                            ),
                                            title: Text(
                                              _serviceLabel(
                                                '${assignment['service_type'] ?? ''}',
                                              ),
                                            ),
                                            subtitle: Text(range),
                                            trailing: canCreate
                                                ? Wrap(
                                                    children: [
                                                      IconButton(
                                                        tooltip:
                                                            'Edit assignment',
                                                        onPressed: () =>
                                                            _editAssignment(
                                                              member,
                                                              assignment,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.edit_outlined,
                                                        ),
                                                      ),
                                                      if (endDate == null)
                                                        IconButton(
                                                          tooltip:
                                                              'End assignment',
                                                          onPressed: () =>
                                                              _endAssignment(
                                                                member,
                                                                assignment,
                                                              ),
                                                          icon: const Icon(
                                                            Icons
                                                                .event_busy_outlined,
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                : null,
                                          );
                                        }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _createAssignment(Map member) async {
    final userId = _id(member['id']);
    if (userId == null) return;

    final assignment = await showDialog<(String, DateTime, DateTime?)>(
      context: context,
      builder: (dialogContext) =>
          _ServiceAssignmentDialog(memberName: '${member['name'] ?? 'Member'}'),
    );
    if (assignment == null || !mounted) return;

    try {
      await ref
          .read(serviceAssignmentsApiProvider)
          .addServiceAssignment(
            userId,
            assignment.$1,
            assignment.$2,
            assignment.$3,
          );
      ref.invalidate(getAssignmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_serviceLabel(assignment.$1)} assignment created for ${member['name'] ?? 'member'}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create assignment: ${_errorMessage(error)}'),
        ),
      );
    }
  }

  Future<void> _editAssignment(Map member, Map current) async {
    final assignmentId = _id(current['id']);
    if (assignmentId == null) return;

    final updated = await showDialog<(String, DateTime, DateTime?)>(
      context: context,
      builder: (_) => _ServiceAssignmentDialog(
        memberName: '${member['name'] ?? 'Member'}',
        initialServiceType: '${current['service_type'] ?? 'publisher'}',
        initialStartDate: _dateValue(current['start_date']),
        initialEndDate: current['end_date'] == null
            ? null
            : _dateValue(current['end_date']),
        isEditing: true,
      ),
    );
    if (updated == null || !mounted) return;

    try {
      await ref
          .read(serviceAssignmentsApiProvider)
          .updateServiceAssignment(
            assignmentId,
            updated.$1,
            updated.$2,
            updated.$3,
          );
      ref.invalidate(getAssignmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service assignment updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update assignment: ${_errorMessage(error)}'),
        ),
      );
    }
  }

  Future<void> _endAssignment(Map member, Map current) async {
    final assignmentId = _id(current['id']);
    final startDate = _dateValue(current['start_date']);
    if (assignmentId == null || startDate.year == 1900) return;

    final today = _dateOnly(DateTime.now());
    final chosenEndDate = await showDatePicker(
      context: context,
      initialDate: today.isBefore(startDate) ? startDate : today,
      firstDate: startDate,
      lastDate: DateTime(2100),
      helpText: 'Select the last day of this service period',
    );
    if (chosenEndDate == null || !mounted) return;

    try {
      await ref
          .read(serviceAssignmentsApiProvider)
          .updateServiceAssignment(
            assignmentId,
            '${current['service_type'] ?? 'publisher'}',
            startDate,
            _dateOnly(chosenEndDate),
          );
      ref.invalidate(getAssignmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member['name'] ?? 'Member'}’s assignment ended on ${_formatDate(chosenEndDate)}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not end assignment: ${_errorMessage(error)}'),
        ),
      );
    }
  }
}

class _ServiceAssignmentDialog extends StatefulWidget {
  const _ServiceAssignmentDialog({
    required this.memberName,
    this.initialServiceType = 'publisher',
    this.initialStartDate,
    this.initialEndDate,
    this.isEditing = false,
  });

  final String memberName;
  final String initialServiceType;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool isEditing;

  @override
  State<_ServiceAssignmentDialog> createState() =>
      _ServiceAssignmentDialogState();
}

class _ServiceAssignmentDialogState extends State<_ServiceAssignmentDialog> {
  static const _serviceTypes = <String, String>{
    'publisher': 'Publisher',
    'auxiliary_pioneer': 'Auxiliary pioneer',
    'regular_pioneer': 'Regular pioneer',
  };

  late String _serviceType;
  late DateTime _startDate;
  DateTime? _endDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _serviceType = _serviceTypes.containsKey(widget.initialServiceType)
        ? widget.initialServiceType
        : 'publisher';
    _startDate = _dateOnly(widget.initialStartDate ?? _today());
    _endDate = widget.initialEndDate == null
        ? null
        : _dateOnly(widget.initialEndDate!);
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.isEditing ? 'Edit service assignment' : 'Assign service type',
    ),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.memberName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _serviceType,
            decoration: const InputDecoration(labelText: 'Service type'),
            items: _serviceTypes.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _serviceType = value);
            },
          ),
          const SizedBox(height: 12),
          _DateChoice(
            label: 'Start date',
            value: MaterialLocalizations.of(
              context,
            ).formatMediumDate(_startDate),
            onPressed: _pickStartDate,
          ),
          _DateChoice(
            label: 'End date',
            value: _endDate == null
                ? 'Ongoing'
                : MaterialLocalizations.of(context).formatMediumDate(_endDate!),
            trailing: _endDate == null
                ? null
                : IconButton(
                    tooltip: 'Make ongoing',
                    onPressed: () => setState(() => _endDate = null),
                    icon: const Icon(Icons.close),
                  ),
            onPressed: _pickEndDate,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _confirm,
        child: Text(widget.isEditing ? 'Save changes' : 'Create assignment'),
      ),
    ],
  );

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() {
      _startDate = _dateOnly(date);
      if (_endDate != null && _endDate!.isBefore(_startDate)) _endDate = null;
      _error = null;
    });
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() {
      _endDate = _dateOnly(date);
      _error = null;
    });
  }

  void _confirm() {
    if (_endDate != null && _endDate!.isBefore(_startDate)) {
      setState(() => _error = 'End date must be on or after the start date.');
      return;
    }
    Navigator.pop(context, (_serviceType, _startDate, _endDate));
  }
}

class _DateChoice extends StatelessWidget {
  const _DateChoice({
    required this.label,
    required this.value,
    required this.onPressed,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 11)),
                      Text(value, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _dateValue(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse('$value') ?? DateTime(1900);
}

String _formatDate(dynamic value) {
  final date = _dateValue(value);
  if (date.year == 1900) return 'Date unavailable';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

int? _id(dynamic value) => value is int ? value : int.tryParse('$value');

String _serviceLabel(String value) => switch (value) {
  'publisher' => 'Publisher',
  'auxiliary_pioneer' => 'Auxiliary pioneer',
  'regular_pioneer' => 'Regular pioneer',
  _ => value,
};

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) return '${data['detail']}';
    return error.message ?? 'Please try again.';
  }
  return '$error';
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
