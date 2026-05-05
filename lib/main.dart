import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Routing
import 'routes/app_router.dart';

/// Theme
import 'core/theme/app_theme.dart';
import 'core/utils/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- HIVE INIT ----------
  await Hive.initFlutter();

  // (Future-ready) Open boxes here if needed
  // await Hive.openBox('appBox');

  await NotificationService().init();

  runApp(const BagCheckApp());
}

class BagCheckApp extends StatelessWidget {
  const BagCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // ---------- THEME ----------
      theme: AppTheme.lightTheme,

      // ---------- ROUTER ----------
      routerConfig: appRouter,

      // ---------- UX IMPROVEMENT ----------
      scrollBehavior: const _NoGlowScrollBehavior(),
    );
  }
}

/// ---------- REMOVE SCROLL GLOW (Premium Feel) ----------
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
