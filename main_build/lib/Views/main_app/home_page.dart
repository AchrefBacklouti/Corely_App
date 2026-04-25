import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/home/home_page_content.dart';
import 'package:main_build/Views/main_app/nutrition/nutrition_page_content.dart';
import 'package:main_build/Views/main_app/settings_page.dart';
import 'package:main_build/Views/main_app/stats/stats_page_content.dart';
import 'package:main_build/Views/main_app/workout/workout_page_content.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0A0A0C);
  static const surface = Color(0xFF111116);
  static const border = Color(0xFF1E1E24);
  static const accent = Color(0xFFC8FF00);
  static const navInactive = Color(0xFF555555);
  static const textPrimary = Color(0xFFFFFFFF);
}

// ─── Main Shell ───────────────────────────────────────────────────────────────
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const _navIcons = [
    Icons.home_filled,
    Icons.fitness_center,
    Icons.show_chart,
    Icons.apple,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
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
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        icons: _navIcons,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Your original logo asset — unchanged
          Image.asset(
            isDarkMode
                ? 'assets/img/logo_dark.png'
                : 'assets/img/logo_light.png',
            width: 75,
          ),

          Row(
            children: [
              // Redesigned avatar with accent gradient
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.accent, Color(0xFF86C900)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppTheme.darkBackground,
                ),
              ),

              const SizedBox(width: 10),

              // Redesigned settings button
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.border),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.settings_outlined,
                    color: palette.textMuted,
                    size: 18,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.icons,
    required this.onTap,
  });

  final int currentIndex;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: palette.navigationBar,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(top: BorderSide(color: palette.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
          (i) => _NavItem(
            icon: icons[i],
            isActive: currentIndex == i,
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? palette.background : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 26 : 22,
              color: isActive ? palette.accent : palette.textMuted,
            ),
            const SizedBox(height: 4),
            // Accent dot indicator under active icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? palette.accent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Design Components ───────────────────────────────────────────────
// Drop these into your HomePageContent, WorkoutPageContent, etc.

/// Dark surface card with subtle border
class FitCard extends StatelessWidget {
  const FitCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 16,
    this.accentBorder = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool accentBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: accentBorder ? _C.accent : _C.border,
          width: accentBorder ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Accent (lime green) filled card
class FitAccentCard extends StatelessWidget {
  const FitAccentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _C.accent,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

/// Uppercase muted section label
class FitSectionLabel extends StatelessWidget {
  const FitSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _C.navInactive,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Bold white page header
class FitPageHeader extends StatelessWidget {
  const FitPageHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: _C.textPrimary,
      ),
    );
  }
}

/// Slim accent-colored progress bar
class FitProgressBar extends StatelessWidget {
  const FitProgressBar({super.key, required this.value, this.height = 5});
  final double value; // 0.0 – 1.0
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: const Color(0xFF222222),
        valueColor: const AlwaysStoppedAnimation<Color>(_C.accent),
      ),
    );
  }
}

/// Full-width primary CTA button
class FitButton extends StatelessWidget {
  const FitButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.accent,
          foregroundColor: _C.bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
