import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/interest/presentation/screens/interest_form_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import '../../features/property/presentation/screens/property_detail_screen.dart';
import '../../features/property/presentation/screens/user_dashboard_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Still loading auth state from local storage
      if (authState.isLoading) return null;

      final user = authState.value;
      final isLoggingIn = state.matchedLocation == '/login';

      // Not authenticated
      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      // Authenticated as Owner
      if (user.isOwner) {
        if (isLoggingIn || state.matchedLocation == '/user-dashboard') {
          return '/owner-dashboard';
        }
        return null;
      }

      // Authenticated as Regular User
      if (user.isUser) {
        if (isLoggingIn || state.matchedLocation == '/owner-dashboard') {
          return '/user-dashboard';
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/user-dashboard',
        builder: (context, state) => const UserDashboardScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PropertyDetailScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/interest/:id',
        redirect: (context, state) {
          final user = ref.read(authProvider).value;
          if (user?.isOwner == true) {
            return '/owner-dashboard';
          }
          return null;
        },
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final propertyName = state.extra is String
              ? state.extra as String
              : 'Selected Property';
          return InterestFormScreen(
            propertyId: id,
            propertyName: propertyName,
          );
        },
      ),
      GoRoute(
        path: '/owner-dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
    ],
  );
});
