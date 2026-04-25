import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Data model for a claimable workout
// ─────────────────────────────────────────────
class WorkoutChallenge {
  final String title;
  final int xp;
  final bool repeatable;
  final IconData icon;
  final Color iconColor;
  bool claimed;

  WorkoutChallenge({
    required this.title,
    required this.xp,
    required this.repeatable,
    required this.icon,
    required this.iconColor,
    this.claimed = false,
  });
}

// ─────────────────────────────────────────────
// Floating XP orb widget (overlay)
// ─────────────────────────────────────────────
class _XpOrb extends StatefulWidget {
  final Offset start;
  final Offset end;
  final Color color;
  final Duration delay;
  final VoidCallback onLand;

  const _XpOrb({
    required this.start,
    required this.end,
    required this.color,
    required this.delay,
    required this.onLand,
  });

  @override
  State<_XpOrb> createState() => _XpOrbState();
}

class _XpOrbState extends State<_XpOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  // Bezier control point — arc upward then curve to the bar
  late final Offset _ctrl1;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _ctrl1 = Offset(
      widget.start.dx +
          (widget.end.dx - widget.start.dx) * 0.35 +
          (rng.nextDouble() - 0.5) * 60,
      widget.start.dy - 60 - rng.nextDouble() * 40,
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 480 + rng.nextInt(120)),
    );

    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    Future.delayed(widget.delay, () {
      if (mounted) {
        _ctrl.forward().whenComplete(() {
          widget.onLand();
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Offset _bezier(double t) {
    final s = widget.start;
    final e = widget.end;
    final c = _ctrl1;
    return Offset(
      (1 - t) * (1 - t) * s.dx + 2 * (1 - t) * t * c.dx + t * t * e.dx,
      (1 - t) * (1 - t) * s.dy + 2 * (1 - t) * t * c.dy + t * t * e.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        final t = _progress.value;
        final pos = _bezier(t);
        // Shrink to nothing as the orb lands
        final scale = t > 0.82
            ? (1.0 - (t - 0.82) / 0.18).clamp(0.0, 1.0)
            : 1.0;
        return Positioned(
          left: pos.dx - 6,
          top: pos.dy - 6,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.7),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Athlete Profile / Challenges Page
// ─────────────────────────────────────────────
class AthleteProfilePage extends StatefulWidget {
  final String athleteName;
  final String athleteSubtitle;
  final int level;
  final int currentXp;
  final int maxXp;

  const AthleteProfilePage({
    super.key,
    this.athleteName = 'Ash',
    this.athleteSubtitle = 'Rookie Athlete',
    this.level = 1,
    this.currentXp = 301,
    this.maxXp = 1500,
  });

  @override
  State<AthleteProfilePage> createState() => _AthleteProfilePageState();
}

class _AthleteProfilePageState extends State<AthleteProfilePage>
    with TickerProviderStateMixin {
  late double _currentXp;

  // Tracks the animated/displayed XP value
  late AnimationController _xpAnimCtrl;
  late Animation<double> _xpAnim;
  double _displayedXp = 0;

  // Key for the XP bar to get its global position
  final GlobalKey _xpBarKey = GlobalKey();

  // Active orb widgets
  final List<Widget> _orbs = [];

  late final List<WorkoutChallenge> _workouts = [
    WorkoutChallenge(
      title: 'Foundational Strength Training (Day 1)',
      xp: 122,
      repeatable: true,
      icon: Icons.fitness_center,
      iconColor: const Color(0xFFc9a6f5),
    ),
    WorkoutChallenge(
      title: 'Focus Cardio Session (High Intensity)',
      xp: 122,
      repeatable: true,
      icon: Icons.directions_run,
      iconColor: const Color(0xFFf0a050),
    ),
    WorkoutChallenge(
      title: 'Endurance Challenge: 5K timed run',
      xp: 250,
      repeatable: false,
      icon: Icons.timer,
      iconColor: const Color(0xFF68c87a),
    ),
    WorkoutChallenge(
      title: 'Nutritional Compliance (Meal Logged)',
      xp: 80,
      repeatable: true,
      icon: Icons.restaurant,
      iconColor: const Color(0xFF81b4f5),
      claimed: true,
    ),
    WorkoutChallenge(
      title: 'End-of-Week Full Body Challenge',
      xp: 40,
      repeatable: true,
      icon: Icons.star_outline,
      iconColor: const Color(0xFFf5c060),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentXp = widget.currentXp.toDouble();
    _displayedXp = _currentXp;

    _xpAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _xpAnim =
        Tween<double>(begin: _currentXp, end: _currentXp).animate(
          CurvedAnimation(parent: _xpAnimCtrl, curve: Curves.easeOut),
        )..addListener(() {
          setState(() => _displayedXp = _xpAnim.value);
        });
  }

  @override
  void dispose() {
    _xpAnimCtrl.dispose();
    super.dispose();
  }

  // ── Called per orb landing ──────────────────
  void _onOrbLand(double xpChunk) {
    final newXp = (_currentXp + xpChunk).clamp(0.0, widget.maxXp.toDouble());
    _currentXp = newXp;

    // Re-drive the tween from the current displayed value to the new target
    _xpAnim =
        Tween<double>(begin: _displayedXp, end: _currentXp).animate(
          CurvedAnimation(parent: _xpAnimCtrl, curve: Curves.easeOut),
        )..addListener(() {
          setState(() => _displayedXp = _xpAnim.value);
        });
    _xpAnimCtrl
      ..reset()
      ..forward();
  }

  // ── Get the global center-right of the XP bar ─
  Offset _getBarTarget() {
    final ro = _xpBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (ro == null) return Offset.zero;
    final pos = ro.localToGlobal(Offset.zero);
    final size = ro.size;
    // Target the fill edge (current progress point)
    final fraction = (_displayedXp / widget.maxXp).clamp(0.0, 1.0);
    return Offset(pos.dx + size.width * fraction, pos.dy + size.height / 2);
  }

  // ── Spawn orbs from button position ──────────
  void _claimXp(WorkoutChallenge w, Offset btnGlobalCenter) {
    if (w.claimed) return;
    setState(() => w.claimed = true);

    const orbCount = 8;
    final xpPerOrb = w.xp / orbCount;
    final barTarget = _getBarTarget();

    const orbColors = [
      Color(0xFFc9a6f5),
      Color(0xFFa880e0),
      Color(0xFFe0c4ff),
      Color(0xFF9070c0),
      Color(0xFFd4a8ff),
    ];

    for (int i = 0; i < orbCount; i++) {
      final delay = Duration(milliseconds: i * 55);
      final color = orbColors[i % orbColors.length];

      late Widget orb;
      orb = _XpOrb(
        start: btnGlobalCenter,
        end: barTarget,
        color: color,
        delay: delay,
        onLand: () {
          _onOrbLand(xpPerOrb);
          setState(() => _orbs.remove(orb));
        },
      );

      setState(() => _orbs.add(orb));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111015),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildAthleteRow(),
                const SizedBox(height: 12),
                _buildSectionLabel('Available Workouts'),
                const SizedBox(height: 8),
                Expanded(child: _buildWorkoutList()),
              ],
            ),
          ),
          // Orb overlay — rendered on top of everything
          ..._orbs,
        ],
      ),
    );
  }

  // ── Top nav bar ──────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Text(
            'Frame 45',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // ── Athlete identity row ──────────────────────
  Widget _buildAthleteRow() {
    final xpFraction = (_displayedXp / widget.maxXp).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1726),
        border: Border.all(color: const Color(0xFF2a2733)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7b5ea7), width: 2),
              gradient: const LinearGradient(
                colors: [Color(0xFF3d2f5a), Color(0xFF1f1b2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Color(0xFFc9a6f5),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Athlete Status'),
                const SizedBox(height: 2),
                Text(
                  widget.athleteName,
                  style: const TextStyle(
                    color: Color(0xFFe8e0f5),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${widget.athleteSubtitle}  ·  Level ${widget.level}',
                  style: const TextStyle(
                    color: Color(0xFF7a6e90),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                // XP bar — keyed so we can find its position
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    key: _xpBarKey,
                    child: LinearProgressIndicator(
                      value: xpFraction,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF2a2538),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF9070c0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // XP chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1f1b2e),
              border: Border.all(color: const Color(0xFF3a3450)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_displayedXp.round()} / ${widget.maxXp} XP',
              style: const TextStyle(
                color: Color(0xFFc9a6f5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scrollable workout list ───────────────────
  Widget _buildWorkoutList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _workouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _WorkoutRow(
        challenge: _workouts[i],
        onClaim: (Offset btnCenter) => _claimXp(_workouts[i], btnCenter),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
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

// ─────────────────────────────────────────────
// Workout row card
// ─────────────────────────────────────────────
class _WorkoutRow extends StatelessWidget {
  final WorkoutChallenge challenge;
  // Returns the global center of the claim button
  final void Function(Offset btnCenter) onClaim;

  const _WorkoutRow({required this.challenge, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1726),
        border: Border.all(color: const Color(0xFF2a2733)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF232030),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(challenge.icon, color: challenge.iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          // Title + XP label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    color: Color(0xFFd0c8e8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '+${challenge.xp} XP'
                  '${challenge.repeatable ? ' · Repeatable' : ''}',
                  style: TextStyle(
                    color: challenge.claimed
                        ? const Color(0xFF4a6640)
                        : const Color(0xFF7a6e90),
                    fontSize: 10,
                    decoration: challenge.claimed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Claim button — uses a Builder to get its own RenderBox
          Builder(
            builder: (btnCtx) => GestureDetector(
              onTap: challenge.claimed
                  ? null
                  : () {
                      final ro = btnCtx.findRenderObject() as RenderBox?;
                      if (ro == null) return;
                      final center = ro.localToGlobal(
                        ro.size.center(Offset.zero),
                      );
                      onClaim(center);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: challenge.claimed
                      ? const Color(0xFF2e2a42)
                      : const Color(0xFF7b5ea7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  challenge.claimed ? 'CLAIMED' : 'CLAIM XP',
                  style: TextStyle(
                    color: challenge.claimed
                        ? const Color(0xFF5a5070)
                        : const Color(0xFFe8d8ff),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Small reusable circle icon button
// ─────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1f1b2e),
          border: Border.all(color: const Color(0xFF2e2a3e)),
        ),
        child: Icon(icon, color: const Color(0xFFc9a6f5), size: 16),
      ),
    );
  }
}
