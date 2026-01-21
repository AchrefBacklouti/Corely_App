import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/home/home_page_content.dart';
import 'package:main_build/Views/main_app/nutrition/nutrition_page_content.dart';
import 'package:main_build/Views/main_app/settings_page.dart';
import 'package:main_build/Views/main_app/stats/stats_page_content.dart';
import 'package:main_build/Views/main_app/workout/workout_page_content.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: const [
                  HomePageContent(),
                  WorkoutPageContent(),
                  StatsPageContent(),
                  NutritionPageContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF191B1F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(icon: Icons.home_filled, index: 0),
          _navItem(icon: Icons.fitness_center, index: 1),
          _navItem(icon: Icons.show_chart, index: 2),
          _navItem(icon: Icons.apple, index: 3),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    final bool isActive = _index == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 0,
          vertical: 10,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF0E0E0E),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Icon(
          icon,
          size: isActive ? 28 : 24,
          color: isActive
              ? (isDarkMode ? Colors.white : Colors.black)
              : (isDarkMode ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Image.asset(
              isDarkMode
                  ? 'assets/img/logo_dark.png'
                  : 'assets/img/logo_light.png',
              width: 75,
            ),
          ],
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDarkMode ? Colors.white12 : Colors.black12,
              child: Icon(
                Icons.person,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              iconSize: 26,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}