import 'package:congregation_reporting/features/auth/screens/reportDetail.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/loginScreen.dart';
import '../../features/auth/screens/publisherHomeScreen.dart';
import '../../features/auth/screens/submitReportScreen.dart';
import '../../features/auth/screens/reportHistoryScreen.dart';
import '../../models/reports.dart';

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
        report: state.extra as Report?,
      ), // Pass the report data to ReportHistoryScreen
    ),
    GoRoute(
      path: '/submitReport',
      builder: (context, state) => const SubmitReportscreen(),
    ),
    GoRoute(
      path: '/report-details',
      builder: (context, state) =>ReportDetailScreen(report: state.extra as Report,),
    ),
  ],
);
