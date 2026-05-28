import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/ai_chat_page.dart';
import 'package:main_build/Views/main_app/chat_history_page.dart';
import 'package:main_build/Views/main_app/home/home_page_content.dart';
import 'package:main_build/data/chat_session_service.dart';
import 'package:main_build/Views/main_app/nutrition/nutrition_page_content.dart';
import 'package:main_build/Views/main_app/settings_page.dart';
import 'package:main_build/Views/main_app/stats/stats_page_content.dart';
import 'package:main_build/Views/main_app/workout/workout_page_content.dart';

// ─────────────────────────────────────────────
// Main Shell
// ─────────────────────────────────────────────
class MainShellPage extends StatefulWidget {
  final String? gender;
  final int? age;
  final double? weight;
  final String? weightUnit;
  final String? heightDisplay;
  final String? goal;
  final int? trainingDays;

  const MainShellPage({
    super.key,
    this.gender,
    this.age,
    this.weight,
    this.weightUnit,
    this.heightDisplay,
    this.goal,
    this.trainingDays,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;
  bool _hasUnreadAiMessage = true;

  static const _navIcons = [
    Icons.home_filled,
    Icons.fitness_center,
    Icons.show_chart,
    Icons.apple,
  ];

  Future<void> _openAiChat() async {
    setState(() => _hasUnreadAiMessage = false);

    final showPicker = await ChatSessionService.shouldShowPicker();
    if (!mounted) return;

    if (showPicker) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatHistoryPage(
            gender: widget.gender,
            age: widget.age,
            weight: widget.weight,
            weightUnit: widget.weightUnit,
            heightDisplay: widget.heightDisplay,
            goal: widget.goal,
            trainingDays: widget.trainingDays,
          ),
        ),
      );
      return;
    }

    // Resume active session or start a new one
    ChatSession? session = await ChatSessionService.getActiveSession();
    if (!mounted) return;
    session ??= await ChatSessionService.createSession();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiChatPage(
          sessionId: session!.id,
          gender: widget.gender,
          age: widget.age,
          weight: widget.weight,
          weightUnit: widget.weightUnit,
          heightDisplay: widget.heightDisplay,
          goal: widget.goal,
          trainingDays: widget.trainingDays,
        ),
      ),
    );
  }

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
      floatingActionButton: _AiChatBubble(
        hasUnread: _hasUnreadAiMessage,
        onTap: _openAiChat,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNav(
        currentIndex: _index,
        icons: _navIcons,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AI Chat Bubble
// ─────────────────────────────────────────────
class _AiChatBubble extends StatefulWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _AiChatBubble({required this.hasUnread, required this.onTap});

  @override
  State<_AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<_AiChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _scaleAnim;
  bool _loopActive = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Damped rotation wobble — wide at first, decays to zero like a ringing bell
    _rotateAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.30, end: 0.30), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.30, end: -0.22), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.22, end: 0.22), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.22, end: -0.12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    // Quick scale pop at the start of each ring, then settles at 1.0
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 9),
    ]).animate(_shakeCtrl);

    if (widget.hasUnread) _startLoop();
  }

  @override
  void didUpdateWidget(_AiChatBubble old) {
    super.didUpdateWidget(old);
    if (!old.hasUnread && widget.hasUnread) {
      _startLoop();
    } else if (old.hasUnread && !widget.hasUnread) {
      _shakeCtrl.stop();
      _shakeCtrl.value = 0;
    }
  }

  Future<void> _startLoop() async {
    if (_loopActive) return;
    _loopActive = true;
    await Future.delayed(const Duration(milliseconds: 600));
    while (mounted && widget.hasUnread) {
      _shakeCtrl.forward(from: 0); // fire-and-forget; delay handles timing
      await Future.delayed(const Duration(milliseconds: 4000)); // 700ms anim + 3.3s pause
    }
    _loopActive = false;
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: Transform.rotate(
          angle: _rotateAnim.value,
          child: child,
        ),
      ),
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppTheme.accent, AppTheme.accent_2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x662979FF),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset('assets/img/bot.png'),
            ),
          ),
        ),
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
                    colors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.6)],
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
