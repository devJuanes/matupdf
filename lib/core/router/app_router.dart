import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/contact/presentation/pages/contact_page.dart';
import '../../features/home/presentation/pages/landing_page.dart';
import '../../features/home/presentation/pages/merge_page.dart';
import '../../features/legal/presentation/pages/privacy_policy_page.dart';
import '../../features/legal/presentation/pages/terms_of_service_page.dart';
import '../constants/app_constants.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LandingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.merge,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MergePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.account,
        pageBuilder: (context, state) {
          final register = state.uri.queryParameters['registro'] == '1';
          final redirect = state.uri.queryParameters['redirect'];
          final mergeAfterAuth = state.uri.queryParameters['merge'] == '1';
          return NoTransitionPage(
            child: AuthPage(
              initialRegister: register,
              redirectTo: redirect,
              mergeAfterAuth: mergeAfterAuth,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.contact,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ContactPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PrivacyPolicyPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: TermsOfServicePage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.uri.path}'),
      ),
    ),
  );
}
