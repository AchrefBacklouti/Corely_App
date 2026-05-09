import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/home/home_page_content.dart';
import 'package:main_build/Views/main_app/nutrition/nutrition_page_content.dart';
import 'package:main_build/Views/main_app/settings_page.dart';
import 'package:main_build/Views/main_app/stats/stats_page_content.dart';
import 'package:main_build/Views/main_app/workout/workout_page_content.dart';

// ─────────────────────────────────────────────
// Main Shell
// ─────────────────────────────────────────────
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
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
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

// ─────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            isDark ? 'assets/img/logo_dark.png' : 'assets/img/logo_light.png',
            width: 75,
          ),
          Row(
            children: [
              // Avatar — accent gradient, icon colour uses background token
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.6)],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person,
                  size: 18,
                  // Black in both modes — accent is always light enough
                  color: Colors.black,
                ),
              ),

              const SizedBox(width: 10),

              // Settings button
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.settings_outlined,
                    color: c.textMuted,
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

// ─────────────────────────────────────────────
// Bottom Navigation
// ─────────────────────────────────────────────
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
    final c = context.colors;

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: c.navigationBar,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(top: BorderSide(color: c.border)),
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
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? c.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 26 : 22,
              color: isActive ? c.accent : c.textMuted,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? c.accent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable Design Components
// ─────────────────────────────────────────────

/// Standard surface card — adapts to dark/light via CorelyColors.
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
    final c = context.colors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: accentBorder ? c.accent : c.border,
          width: accentBorder ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Accent-filled streak card — intentionally always yellow, ignore theme.
/// Use this for the daily streak widget only.
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
    // Deliberately NOT reading context.colors — this card is always the
    // brand accent colour regardless of dark/light mode (streak card).
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

/// Uppercase muted section label.
class FitSectionLabel extends StatelessWidget {
  const FitSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: c.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Bold page header — uses theme textPrimary.
class FitPageHeader extends StatelessWidget {
  const FitPageHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.displayMedium?.copyWith(letterSpacing: 1.5),
    );
  }
}

/// Slim accent-coloured progress bar.
class FitProgressBar extends StatelessWidget {
  const FitProgressBar({super.key, required this.value, this.height = 5});
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: c.border,
        valueColor: AlwaysStoppedAnimation<Color>(c.accent),
      ),
    );
  }
}

/// Full-width primary CTA button.
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
        // Inherits ElevatedButtonThemeData; only override shape/padding here.
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
