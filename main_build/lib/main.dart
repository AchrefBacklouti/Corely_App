import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Theme/theme_provider.dart';
import 'package:main_build/Theme/theme_scope.dart';
import 'package:main_build/Views/auth/loading_page.dart';
import 'package:main_build/Views/auth/welcome_page.dart';
import 'package:main_build/Views/auth/login_page.dart';
import 'package:main_build/Views/main_app/home_page.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/exercise_cache_service.dart';
import 'package:main_build/data/workout_progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalPlanService.init();
  await ExerciseCacheService.init();
  await WorkoutProgressService.init();
  runApp(CorelyApp());
}

class CorelyApp extends StatefulWidget {
  const CorelyApp({super.key});

  @override
  State<CorelyApp> createState() => _CorelyAppState();
}

class _CorelyAppState extends State<CorelyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, _) {
        return ThemeScope(
          controller: _themeProvider,
          child: MaterialApp(
            title: 'Corely',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoadingPage(),
              '/welcome': (context) => StartPage(themeProvider: _themeProvider),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const MainShellPage(),
            },
          ),
        );
      },
    );
  }
}
