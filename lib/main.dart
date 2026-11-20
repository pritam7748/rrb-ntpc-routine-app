import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/alarm_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline storage & default RRB NTPC routines
  await StorageService.init();

  // Initialize background notification & persistent alarm engine
  await AlarmService.init(rootNavigatorKey);

  runApp(const RrbNtpcRoutineApp());
}

class RrbNtpcRoutineApp extends StatelessWidget {
  const RrbNtpcRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasPin = StorageService.getUserPin() != null;
    final bool isSecurityOn = StorageService.isSecurityEnabled();

    // If PIN is enabled and set, start with Lock Screen
    final Widget initialScreen = (isSecurityOn && hasPin)
        ? const LockScreen()
        : const HomeScreen();

    return MaterialApp(
      title: 'RRB NTPC Routine & Study Companion',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: AppTheme.darkTheme,
      home: initialScreen,
    );
  }
}
