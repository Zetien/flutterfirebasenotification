import 'package:go_router/go_router.dart';
import 'package:push_notificacion_app/presentation/screeens/details_screen.dart';
import 'package:push_notificacion_app/presentation/screeens/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/push-details/:messageId',
      builder: (context, state) =>
          DetailsScreen(pushMessageId: state.pathParameters['messageId'] ?? ''),
    ),
  ],
);
