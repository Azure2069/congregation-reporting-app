import 'package:congregation_reporting/features/auth/screens/reportDetail.dart';
import 'package:congregation_reporting/features/overseer/screens/group_members_screen.dart';
import 'package:congregation_reporting/models/user.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/loginScreen.dart';
import '../../features/auth/screens/publisherHomeScreen.dart';
import '../../features/auth/screens/submitReportScreen.dart';
import '../../features/auth/screens/reportHistoryScreen.dart';
import '../../features/overseer/screens/member_reports_screen.dart';
import '../../models/reports.dart';
import '../../features/overseer/screens/home_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const PublisherHomeScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(
      path: '/reportHistory',
      builder: (context, state) => ReportHistoryScreen(
       
      ), // Pass the report data to ReportHistoryScreen
    ),
    GoRoute(
      path: '/submitReport',
      builder: (context, state) => const SubmitReportscreen(),
    ),
    GoRoute(path: '/overseerHome', builder: (context, state) => const OverseerHomeScreen()),
    GoRoute(
      path: '/report-details',
      builder: (context, state) =>ReportDetailScreen(report: state.extra as Report,),
    ),
    GoRoute(path: '/allMembers', builder: (context, state) => const GroupMembersScreen()
    ),
    GoRoute(path: '/updateReport',
    builder: (context, state) => SubmitReportscreen(updateReport: state.extra as Report,),
    ),
        GoRoute(path: '/memberReport', builder:(context, state)=>MemberReportsScreen(
          member: state.extra as User
        ))

  ],
);
