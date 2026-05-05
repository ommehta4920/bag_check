import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/set_pin_screen.dart';
import '../features/onboarding/child_profile_screen.dart';
import '../features/onboarding/timetable_screen.dart';
import '../features/onboarding/fixed_items_screen.dart';
import '../features/onboarding/reminder_screen.dart';
import '../features/onboarding/preview_screen.dart';

import '../features/home/home_screen.dart';

import '../features/parent/parent_pin_screen.dart';
import '../features/parent/parent_dashboard.dart';
import '../features/parent/parent_verification_screen.dart';

import '../features/child/success_screen.dart';

import '../features/parent/edit/edit_timetable_screen.dart';
import '../features/parent/edit/edit_fixed_items_screen.dart';
import '../features/parent/edit/edit_profile_screen.dart';
import '../features/parent/settings/change_pin_screen.dart';

CustomTransitionPage buildPageWithTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
    ) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      );

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
  );
}

/// ================= ROUTE CONSTANTS =================
class AppRoutes {
  static const splash = '/';
  static const setPin = '/set-pin';
  static const childProfile = '/child-profile';
  static const timetable = '/timetable';
  static const fixedItems = '/fixed-items';
  static const reminder = '/reminder';
  static const preview = '/preview';

  static const home = '/home';

  static const parentPin = '/parent-pin';
  static const parentDashboard = '/parent-dashboard';
  static const parentVerify = '/parent-verify';

  static const success = '/success';

  static const editTimetable = '/edit-timetable';
  static const editFixedItems = '/edit-fixed-items';
  static const editProfile = '/edit-profile';
  static const changePin = '/change-pin';
}

/// ================= TRANSITION =================
CustomTransitionPage buildPage(
    BuildContext context,
    GoRouterState state,
    Widget child,
    ) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// ================= ROUTER =================
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  routes: [
    /// -------- ONBOARDING --------
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (c, s) => buildPage(c, s, const SplashScreen()),
    ),
    GoRoute(
      path: AppRoutes.setPin,
      pageBuilder: (c, s) => buildPage(c, s, const SetPinScreen()),
    ),
    GoRoute(
      path: AppRoutes.childProfile,
      pageBuilder: (c, s) => buildPage(c, s, const ChildProfileScreen()),
    ),
    GoRoute(
      path: AppRoutes.timetable,
      pageBuilder: (c, s) => buildPage(c, s, const TimetableScreen()),
    ),
    GoRoute(
      path: AppRoutes.fixedItems,
      pageBuilder: (c, s) => buildPage(c, s, const FixedItemsScreen()),
    ),
    GoRoute(
      path: AppRoutes.reminder,
      pageBuilder: (c, s) => buildPage(c, s, const ReminderScreen()),
    ),
    GoRoute(
      path: AppRoutes.preview,
      pageBuilder: (c, s) => buildPage(c, s, const PreviewScreen()),
    ),

    /// -------- MAIN --------
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (c, s) => buildPage(c, s, const HomeScreen()),
    ),

    /// -------- PARENT --------
    GoRoute(
      path: '/parent-pin',
      pageBuilder: (c, s) {
        final isVerification = s.extra == true;

        return buildPageWithTransition(
          c,
          s,
          ParentPinScreen(isVerification: isVerification),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.parentDashboard,
      pageBuilder: (c, s) => buildPage(c, s, const ParentDashboard()),
    ),
    GoRoute(
      path: '/parent-verify',
      pageBuilder: (c, s) =>
          buildPageWithTransition(c, s, const ParentVerificationScreen()),
    ),

    /// -------- SUCCESS --------
    GoRoute(
      path: AppRoutes.success,
      pageBuilder: (c, s) {
        final streak = (s.extra is int) ? s.extra as int : 0;
        return buildPage(c, s, SuccessScreen(streak: streak));
      },
    ),

    /// -------- EDIT --------
    GoRoute(
      path: AppRoutes.editTimetable,
      pageBuilder: (c, s) =>
          buildPage(c, s, const EditTimetableScreen()),
    ),
    GoRoute(
      path: AppRoutes.editFixedItems,
      pageBuilder: (c, s) =>
          buildPage(c, s, const EditFixedItemsScreen()),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      pageBuilder: (c, s) =>
          buildPage(c, s, const EditProfileScreen()),
    ),
    GoRoute(
      path: AppRoutes.changePin,
      pageBuilder: (c, s) =>
          buildPage(c, s, const ChangePinScreen()),
    ),
  ],
);