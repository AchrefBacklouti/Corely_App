import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Theme/theme_provider.dart';

import 'package:main_build/Views/on_boarding/on_boarding.dart';

class StartPage extends StatefulWidget {
  final ThemeProvider? themeProvider;

  const StartPage({super.key, this.themeProvider});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/img/wpbg.jpg', fit: BoxFit.cover),
          ),

          // Overlay color
          Container(
            color: isDarkMode
                ? AppTheme.darkBackground.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.72),
          ),

          // Theme toggle button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppTheme.yellow,
                  onPressed: () {
                    widget.themeProvider?.toggleTheme();
                  },
                  child: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    isDarkMode
                        ? 'assets/img/logo_dark.png'
                        : 'assets/img/logo_light.png',
                    fit: BoxFit.cover,
                  ),

                  // Subtitle
                  Text(
                    'Your all-in-one fitness journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 27,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 300),

                  // Start now button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellow,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CorelyOnboardingFlow(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'start now',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            '>',
                            style: TextStyle(
                              fontSize: 27,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Log in button
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 27,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
