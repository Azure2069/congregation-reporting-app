import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/user_role/user_role_api.dart';
import '../../../core/api/users/users_api.dart';

class OverseerHomeScreen extends ConsumerStatefulWidget {
  const OverseerHomeScreen({super.key});

  @override
  ConsumerState<OverseerHomeScreen> createState() => _OverseerHomeScreenState();
}

class _OverseerHomeScreenState extends ConsumerState<OverseerHomeScreen> {
  bool _isAuthorized = false;
  bool _isGroupOverseer = false;
  bool _isServiceOverseer = false;

  @override
  void initState() {
    super.initState();
    _checkDeskAccess();
  }

  Future<void> _checkDeskAccess() async {
    try {
      final user = await ref.read(getcurrentUserProvider.future);
      final userId = user['id'];
      if (userId is! int) {
        if (mounted) context.go('/home');
        return;
      }

      final roles = await ref.read(getAllUserRolesProvider(userId).future);
      final roleNames = roles is List
          ? roles
                .whereType<Map>()
                .map((record) => record['role'])
                .whereType<String>()
                .toSet()
          : <String>{};
      final canAccessDesk = roleNames.contains('elder');
      if (!mounted) return;

      if (!canAccessDesk) {
        context.go('/home');
        return;
      }

      setState(() {
        _isAuthorized = true;
        _isGroupOverseer = roleNames.contains('group_overseer');
        _isServiceOverseer = roleNames.contains('service_overseer');
      });
    } catch (_) {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Elders dashboard')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF003C33),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ELDERS’ DASHBOARD',
                      style: TextStyle(
                        color: Color(0xFFB6D5CA),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reports and members',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A clear view of congregation reports and members.',
                      style: TextStyle(color: Color(0xFFE0ECE7), height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'WORKSPACE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF75758A),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _DeskAction(
                icon: Icons.groups_outlined,
                title: 'Members by group',
                detail: 'Browse members without opening their reports',
                onTap: () => context.push('/allMembers'),
              ),
              const SizedBox(height: 12),
              _DeskAction(
                icon: Icons.badge_outlined,
                title: 'Member roles',
                detail: 'Assign elder, secretary, and service overseer roles',
                onTap: () => context.push('/manageRoles'),
              ),
              if (_isServiceOverseer) ...[
                const SizedBox(height: 12),
                _DeskAction(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'Service assignments',
                  detail: 'Set publisher and pioneer service periods',
                  onTap: () => context.push('/serviceAssignments'),
                ),
              ],
              const SizedBox(height: 12),
              _DeskAction(
                icon: Icons.library_books_outlined,
                title: 'All reports',
                detail: 'Browse reports across the congregation',
                onTap: () => context.push('/allReports'),
              ),
              if (_isGroupOverseer) ...[
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => context.push('/submitReport'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Submit a report'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeskAction extends StatelessWidget {
  const _DeskAction({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEDFCE9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF003C33)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(color: Color(0xFF555555)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF003C33)),
          ],
        ),
      ),
    ),
  );
}
