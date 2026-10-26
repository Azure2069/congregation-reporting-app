import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_access_gate.dart';
import '../../features/admin/screens/admin_groups_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/role_management_screen.dart';
import '../../features/admin/screens/service_assignment_management_screen.dart';
import '../../features/admin/screens/user_role_gate.dart';
import '../../features/auth/screens/auth_screen_check.dart';
import '../../features/auth/screens/loginScreen.dart';
import '../../features/auth/screens/publisher_home_screen.dart';
import '../../features/auth/screens/reportDetail.dart';
import '../../features/auth/screens/reportHistoryScreen.dart';
import '../../features/auth/screens/submitReportScreen.dart';
import '../../features/auth/providers/token_provider.dart';
import '../../features/overseer/screens/all_reports.dart';
import '../../features/overseer/screens/current_month_reports.dart';
import '../../features/overseer/screens/eldersHomeScreen.dart';
import '../../features/overseer/screens/group_members_screen.dart';
import '../../features/overseer/screens/member_reports_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  final router = GoRouter(
    initialLocation: '/auth-check',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublic = path == '/auth-check' || path == '/login';
      final token = ref.read(authTokenProvider);
      if (!isPublic && (token == null || token.isEmpty)) {
        return Uri(
          path: '/auth-check',
          queryParameters: {'redirectTo': state.uri.toString()},
        ).toString();
      }
      if (path == '/login' && token != null && token.isNotEmpty) {
        return '/auth-check';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth-check',
        builder: (context, state) => AuthCheckScreen(
          redirectTo: state.uri.queryParameters['redirectTo'],
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(redirectTo: state.uri.queryParameters['redirectTo']),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const PublisherHomeScreen(),
      ),
      GoRoute(
        path: '/adminHome',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/adminUsers',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/adminGroups',
        builder: (context, state) => const AdminGroupsScreen(),
      ),
      GoRoute(
        path: '/manageRoles',
        builder: (context, state) => UserRoleGate(
          requiredRoles: const {'elder'},
          child: const RoleManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/serviceAssignments',
        builder: (context, state) => UserRoleGate(
          requiredRoles: const {'elder'},
          child: const ServiceAssignmentManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/reportHistory',
        builder: (context, state) => ReportHistoryScreen(),
      ),
      GoRoute(
        path: '/submitReport',
        builder: (context, state) => const SubmitReportscreen(),
      ),
      GoRoute(
        path: '/overseerHome',
        builder: (context, state) => const OverseerHomeScreen(),
      ),
      GoRoute(
        path: '/report-details',
        builder: (context, state) => state.extra is Map
            ? ReportDetailScreen(report: state.extra as Map)
            : const _InvalidRouteDataScreen(
                message: 'The selected report is unavailable.',
              ),
      ),
      GoRoute(
        path: '/allMembers',
        builder: (context, state) => AdminAccessGate(
          allowElder: true,
          child: const GroupMembersScreen(),
        ),
      ),
      GoRoute(
        path: '/updateReport',
        builder: (context, state) => state.extra is Map
            ? SubmitReportscreen(report: state.extra as Map)
            : const _InvalidRouteDataScreen(
                message: 'The report to update is unavailable.',
              ),
      ),
      GoRoute(
        path: '/memberReport',
        builder: (context, state) => state.extra is Map
            ? AdminAccessGate(
                allowElder: true,
                child: MemberReportsScreen(member: state.extra as Map),
              )
            : const _InvalidRouteDataScreen(
                message: 'The selected member is unavailable.',
              ),
      ),
      GoRoute(
        path: '/currentReports',
        builder: (context, state) => UserRoleGate(
          requiredRoles: const {'elder', 'group_overseer'},
          child: const CurrentMonthReports(),
        ),
      ),
      GoRoute(
        path: '/allReports',
        builder: (context, state) =>
            AdminAccessGate(allowElder: true, child: AllReports()),
      ),
      GoRoute(
        path: '/secretaryHome',
        builder: (context, state) => UserRoleGate(
          requiredRoles: const {'elder', 'secretary'},
          child: const AllReports(),
        ),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authTokenProvider, (_, __) => notifyListeners());
  }
}

class _InvalidRouteDataScreen extends StatelessWidget {
  const _InvalidRouteDataScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Unable to open page')),
    body: Center(child: Text(message)),
  );
}
