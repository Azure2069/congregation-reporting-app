import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/date_labels.dart';
import '../providers/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/users/users_api.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/congregation/congregation_api.dart';
import '../../../core/api/reports/reports_api.dart';
import '../../../core/api/service_assignments/service_assignments_api.dart';
import '../../reports/widgets/monthly_report_status.dart';

class PublisherHomeScreen extends ConsumerStatefulWidget {
  const PublisherHomeScreen({super.key});

  @override
  ConsumerState<PublisherHomeScreen> createState() => _PublisherHomeScreen();
}

class _PublisherHomeScreen extends ConsumerState<PublisherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(getcurrentUserProvider);
    final currentUserId = _userId(currentUser.asData?.value?['id']);
    final reportingMonth = DateLabels.currentReportingMonth();
    final congregation = ref.watch(getMyCongregationProvider);
    final reports = ref.watch(getMyReportsProvider);
    return Scaffold(
      appBar: AppBar(
        title: congregation.when(
          loading: () => const Text('Your congregation'),
          error: (error, stackTrace) => const Text('Congregation report'),
          data: (congregation) =>
              Text(congregation['name'] ?? 'Congregation report'),
        ),
        actions: [
          if (currentUserId != null)
            IconButton(
              tooltip: 'Change password',
              onPressed: () => _showChangePasswordDialog(currentUserId),
              icon: const Icon(Icons.lock_reset_rounded),
            ),
          IconButton(
            tooltip: 'Log out',
            onPressed: _confirmAndLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            currentUser.when(
              loading: () => const CircularProgressIndicator(),
              error: ((error, stackTrace) {
                if (error is DioException &&
                    error.response?.statusCode == 401) {
                  ref.read(authTokenProvider.notifier).state = null;
                }
                if (ref.read(authTokenProvider.notifier).state == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) context.go('/login');
                  });
                }
                return const Text('Failed to load your profile.');
              }),
              data: (response) {
                final user = response;
                final roles = ref.watch(
                  getAllUserRolesProvider(user['id'] as int),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003C33),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'YOUR MONTHLY OVERVIEW',
                                  style: TextStyle(
                                    color: Color(0xFFB6D5CA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Welcome, ${user['name']?.toString().split(' ').first ?? 'Publisher'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Your ministry activity, all in one place.',
                                  style: TextStyle(
                                    color: Color(0xFFE0ECE7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0x1FFFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_stories_outlined,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    roles.when(
                      loading: () => const SizedBox.shrink(),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                      data: (roleRecords) {
                        final roleNames = roleRecords is List
                            ? roleRecords
                                  .whereType<Map>()
                                  .map((r) => r['role'])
                                  .whereType<String>()
                                  .toSet()
                            : <String>{};
                        if (!roleNames.contains('elder') &&
                            !roleNames.contains('group_overseer') &&
                            !roleNames.contains('secretary') &&
                            !roleNames.contains('admin')) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              if (roleNames.contains('group_overseer'))
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.push('/currentReports'),
                                  icon: const Icon(Icons.groups_outlined),
                                  label: const Text('Group overseer dashboard'),
                                ),
                              if (roleNames.contains('elder'))
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/overseerHome'),
                                  icon: const Icon(
                                    Icons.account_balance_outlined,
                                  ),
                                  label: const Text('Elders dashboard'),
                                ),
                              if (roleNames.contains('secretary'))
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push('/secretaryHome'),
                                  icon: const Icon(Icons.assignment_outlined),
                                  label: const Text('Secretary dashboard'),
                                ),
                              if (roleNames.contains('admin'))
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/adminHome'),
                                  icon: const Icon(
                                    Icons.admin_panel_settings_outlined,
                                  ),
                                  label: const Text('Administration'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            Text(
              'This month',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 14),
            Card(
              color: const Color(0xFFFAFAF8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly report',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFCE9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: currentUser.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stackTrace) =>
                                const Text("User load fail"),
                            data: (user) {
                              return MonthlyReportStatus(
                                userId: user['id'] as int,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      DateLabels.monthYear(reportingMonth),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    currentUser.when(
                      loading: () => const Text(
                        'Loading service type…',
                        style: TextStyle(color: Color(0xFF555555)),
                      ),
                      error: (error, stackTrace) => const Text(
                        'Unable to load service type',
                        style: TextStyle(color: Color(0xFF555555)),
                      ),
                      data: (user) => _CurrentServiceTypeLabel(
                        userId: user['id'] as int,
                        reportingMonth: reportingMonth,
                        style: const TextStyle(color: Color(0xFF555555)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/submitReport'),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Submit report'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF003C33),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Service status',
                            style: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          currentUser.when(
                            loading: () => const Text('Loading…'),
                            error: (error, stackTrace) =>
                                const Text('Unavailable'),
                            data: (user) => _CurrentServiceTypeLabel(
                              userId: user['id'] as int,
                              reportingMonth: reportingMonth,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => context.push('/reportHistory'),
                      child: const Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: Color(0xFF003C33),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Report history',
                              style: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View reports',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent reports',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () => context.push('/reportHistory'),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            reports.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) =>
                  const Text('Reports could not be loaded.'),
              data: (reports) {
                List list3 = [];
                if (reports.isEmpty) {
                  return Card(
                    color: const Color(0xFFFAFAF8),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF003C33),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('No reports have been submitted yet.'),
                          ),
                          TextButton(
                            onPressed: () => context.push('/submitReport'),
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                for (int i = 0; i < reports.length && i < 3; i++) {
                  list3.add(reports[i]);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list3.length,
                  itemBuilder: (BuildContext context, int index) {
                    final report = list3[index] as Map;
                    final month = DateTime.tryParse(
                      '${report['reporting_month']}',
                    );
                    final status = '${report['status'] ?? 'unknown'}';
                    final statusLabel = status.isEmpty
                        ? 'Unknown'
                        : '${status[0].toUpperCase()}${status.substring(1)}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFCE9),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF003C33),
                          ),
                        ),
                        title: Text(
                          month == null
                              ? 'Monthly report'
                              : DateLabels.monthYear(month),
                        ),
                        subtitle: Text(
                          'Open report details',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFCE9),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Color(0xFF003C33),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () =>
                            context.push('/report-details', extra: report),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(int userId) async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var showNewPassword = false;
    var showConfirmPassword = false;

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change password'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: !showNewPassword,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'New password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => showNewPassword = !showNewPassword,
                            ),
                            icon: Icon(
                              showNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = value?.trim() ?? '';
                          if (password.isEmpty) {
                            return 'Enter a new password.';
                          }
                          if (password.length < 8) {
                            return 'Use at least 8 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => showConfirmPassword = !showConfirmPassword,
                            ),
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = value?.trim() ?? '';
                          if (password.isEmpty) {
                            return 'Confirm your new password.';
                          }
                          if (password != newPasswordController.text.trim()) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save password'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldUpdate != true) {
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      return;
    }

    final newPassword = newPasswordController.text.trim();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    try {
      await ref.read(usersApiProvider).updatePassword(userId, newPassword);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password updated successfully.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update password: ${_errorMessage(error)}'),
        ),
      );
    }
  }

  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to view reports.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;

    try {
      await ref.read(usersApiProvider).logout();
    } catch (_) {
      // Clear the local session even if the server session already expired.
    } finally {
      try {
        await ref.read(tokenStorageProvider).deleteToken();
      } catch (_) {
        // Continue to the signed-out screen if local storage is unavailable.
      }
      ref.read(authTokenProvider.notifier).state = null;
      ref.invalidate(getcurrentUserProvider);
      ref.invalidate(getUserRolesProvider);
      ref.invalidate(getMyCongregationProvider);
      ref.invalidate(getMyReportsProvider);
      if (mounted) context.go('/login');
    }
  }
}

int? _userId(dynamic value) => value is int ? value : int.tryParse('$value');

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) {
      return '${data['detail']}';
    }
    return error.message ?? 'Please try again.';
  }
  return '$error';
}

class _CurrentServiceTypeLabel extends ConsumerWidget {
  const _CurrentServiceTypeLabel({
    required this.userId,
    required this.reportingMonth,
    required this.style,
  });

  final int userId;
  final DateTime reportingMonth;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(
      checkServiceAssignmentProvider((userId, reportingMonth)),
    );

    return assignments.when(
      loading: () => Text('Loading service type…', style: style),
      error: (error, stackTrace) =>
          Text('Unable to load service type', style: style),
      data: (records) {
        if (records is! List) {
          return Text('Unable to load service type', style: style);
        }

        final serviceTypes = records
            .whereType<Map>()
            .map((record) => record['service_type'])
            .whereType<String>()
            .where((type) => type.trim().isNotEmpty)
            .toSet();

        if (serviceTypes.isEmpty) {
          return Text('No service assignment', style: style);
        }

        final labels = serviceTypes
            .map((type) {
              switch (type) {
                case 'publisher':
                  return 'Publisher';
                case 'auxiliary_pioneer':
                  return 'Auxiliary Pioneer';
                case 'regular_pioneer':
                  return 'Regular Pioneer';
                default:
                  return type
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map(
                        (word) => word.isEmpty
                            ? word
                            : '${word[0].toUpperCase()}${word.substring(1)}',
                      )
                      .join(' ');
              }
            })
            .join(', ');

        return Text(labels, style: style);
      },
    );
  }
}
