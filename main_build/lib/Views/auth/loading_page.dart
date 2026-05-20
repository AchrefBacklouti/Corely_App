import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/data/supabase_service.dart';
import 'package:main_build/Controllers/user_provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), _routeFromLocalCache);
  }

  Future<void> _routeFromLocalCache() async {
    if (!mounted) return;

    final hasLocalProfile = await SupabaseService.hasLocalUserProfile();
    if (!mounted) return;

    if (hasLocalProfile) {
      final cachedProfile = await SupabaseService.getLocalUserProfile();
      if (!mounted) return;
      if (cachedProfile != null) {
        UserProvider.instance.setUserProfile(cachedProfile);
      }
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isDarkMode
                    ? 'assets/img/logo_dark.png'
                    : 'assets/img/logo_light.png',
                width: 200,
              ),
              const SizedBox(height: 20),
              Text(
                "Built for progress. Powered by you.",
                style: TextStyle(color: palette.textSecondary, fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
