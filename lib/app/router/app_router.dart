import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Splash')));
        },
      ),

      GoRoute(
        path: RouteConstants.onboarding,
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Onboarding')));
        },
      ),

      GoRoute(
        path: RouteConstants.signIn,
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Sign In')));
        },
      ),
    ],
  );
});
