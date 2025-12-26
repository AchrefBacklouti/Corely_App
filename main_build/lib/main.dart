import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/auth/loading_page.dart';
import 'package:main_build/Views/auth/login_page.dart';
import 'package:main_build/Views/auth/welcome_page.dart';

void main() {
  runApp(CorelyApp());
}

class CorelyApp extends StatelessWidget {
  const CorelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // default dark mode
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingPage(),
        '/welcome': (context) => const StartPage(),
        '/login': (context) => const StartPage(),
      },
    );
  }
}
