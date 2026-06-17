import 'package:go_router/go_router.dart';

import '../../../features/auth/email_verification_screen.dart';
import '../../../features/auth/forgot_password_screen.dart';
import '../../../features/auth/login_screen.dart';
import '../../../features/auth/signup_screen.dart';
import '../app_router.dart' show AppRoute;

List<RouteBase> authRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/login',
      name: AppRoute.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: AppRoute.signup.name,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      name: AppRoute.verifyEmail.name,
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return EmailVerificationScreen(token: token);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: AppRoute.forgotPassword.name,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
  ];
}
