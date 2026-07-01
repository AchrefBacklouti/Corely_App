import 'package:flutter/material.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final int xp;
  final bool isUnlocked;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.xp,
    required this.isUnlocked,
  });
}

// ─── Achievement definitions ──────────────────────────────────────────────────

const _achievements = [
  Achievement(
    title: 'First Step',
    description: 'Complete your very first workout',
    icon: Icons.flag_rounded,
    iconColor: Color(0xFF68c87a),
    xp: 100,
    isUnlocked: true,
  ),
  Achievement(
    title: 'XP Starter',
    description: 'Earn your first 100 XP',
    icon: Icons.bolt_rounded,
    iconColor: Color(0xFFf5c060),
    xp: 50,
    isUnlocked: true,
  ),
  Achievement(
    title: 'Consistency',
    description: 'Work out 7 days in a row',
    icon: Icons.calendar_today_rounded,
    iconColor: Color(0xFF81b4f5),
    xp: 300,
    isUnlocked: false,
  ),
  Achievement(
    title: 'Century Club',
    description: 'Complete 100 workouts total',
    icon: Icons.fitness_center,
    iconColor: Color(0xFFc9a6f5),
    xp: 500,
    isUnlocked: false,
  ),
  Achievement(
    title: 'Iron Will',
    description: 'Maintain a 30-day workout streak',
    icon: Icons.local_fire_department_rounded,
    iconColor: Color(0xFFf0a050),
    xp: 1000,
    isUnlocked: false,
  ),
  Achievement(
    title: 'Level Up',
    description: 'Reach Level 5',
    icon: Icons.arrow_upward_rounded,
    iconColor: Color(0xFF68c87a),
    xp: 250,
    isUnlocked: false,
  ),
  Achievement(
    title: 'XP King',
    description: 'Earn 10,000 XP in total',
    icon: Icons.emoji_events_rounded,
    iconColor: Color(0xFFf5c060),
    xp: 2000,
    isUnlocked: false,
  ),
  Achievement(
    title: 'Cardio Beast',
    description: 'Complete 50 cardio sessions',
    icon: Icons.directions_run_rounded,
    iconColor: Color(0xFF81b4f5),
    xp: 400,
    isUnlocked: false,
  ),
  Achievement(
    title: 'Strength Legend',
    description: 'Claim all strength challenges 10 times',
    icon: Icons.sports_gymnastics,
    iconColor: Color(0xFFc9a6f5),
    xp: 750,
    isUnlocked: false,
  ),
  Achievement(
    title: 'Early Bird',
    description: 'Log a workout before 7 AM',
    icon: Icons.wb_sunny_rounded,
    iconColor: Color(0xFFf0a050),
    xp: 150,
    isUnlocked: false,
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.isUnlocked).toList();
    final locked = _achievements.where((a) => !a.isUnlocked).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF111015),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSummaryBanner(unlocked.length, _achievements.length),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (unlocked.isNotEmpty) ...[
                    _sectionLabel('Unlocked — ${unlocked.length}'),
                    const SizedBox(height: 8),
                    ...unlocked.map((a) => _AchievementTile(achievement: a)),
                    const SizedBox(height: 20),
                  ],
                  if (locked.isNotEmpty) ...[
                    _sectionLabel('Locked — ${locked.length}'),
                    const SizedBox(height: 8),
                    ...locked.map((a) => _AchievementTile(achievement: a)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1f1b2e),
                border: Border.all(color: const Color(0xFF2e2a3e)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFFc9a6f5),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/img/achieve.png', width: 26, height: 26),
          const SizedBox(width: 8),
          const Text(
            'Achievements',
            style: TextStyle(
              color: Color(0xFFe8e0f5),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(int unlocked, int total) {
    final progress = unlocked / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1726),
        border: Border.all(color: const Color(0xFF2a2733)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked of $total unlocked',
                  style: const TextStyle(
                    color: Color(0xFFe8e0f5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2a2538),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF9070c0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1f1b2e),
              border: Border.all(color: const Color(0xFF3a3450)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Color(0xFFc9a6f5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      '[ ${text.toUpperCase()} ]',
      style: const TextStyle(
        color: Color(0xFF4a4460),
        fontSize: 9,
        letterSpacing: 2,
        fontFamily: 'monospace',
      ),
    ),
  );
}

// ─── Achievement tile ──────────────────────────────────────────────────────────

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1726),
          border: Border.all(
            color: unlocked
                ? const Color(0xFF3a2f52)
                : const Color(0xFF2a2733),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon box
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? achievement.iconColor.withValues(alpha: 0.12)
                        : const Color(0xFF1f1b2e),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: unlocked
                          ? achievement.iconColor.withValues(alpha: 0.3)
                          : const Color(0xFF2a2538),
                    ),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: unlocked
                        ? achievement.iconColor
                        : const Color(0xFF3a3450),
                    size: 22,
                  ),
                ),
                if (!unlocked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1a1726),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF4a4060),
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      color: unlocked
                          ? const Color(0xFFe8e0f5)
                          : const Color(0xFF4a4060),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: unlocked
                          ? const Color(0xFF7a6e90)
                          : const Color(0xFF3a3450),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // XP chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: unlocked
                    ? const Color(0xFF2a1f3d)
                    : const Color(0xFF1f1b2e),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFF5a3a7a)
                      : const Color(0xFF2a2538),
                ),
              ),
              child: Text(
                '+${achievement.xp} XP',
                style: TextStyle(
                  color: unlocked
                      ? const Color(0xFFc9a6f5)
                      : const Color(0xFF4a4060),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
