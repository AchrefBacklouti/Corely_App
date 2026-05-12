import 'package:main_build/Views/auth/signup_page.dart';
import 'package:flutter/material.dart';
// import 'package:main_build/Views/main_app/home_page.dart';
import 'package:main_build/Theme/app_theme.dart';

class UserSummary extends StatelessWidget {
  final String gender;
  final int age;
  final double weight;
  final String heightDisplay;
  final String goal;
  final int trainingDays;
  final String weightUnit;

  const UserSummary({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.heightDisplay,
    required this.goal,
    required this.trainingDays,
    required this.weightUnit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: c.textPrimary),
                ),
              ),
              // Title
              Text(
                "You're all set up!!",
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Everything's ready for your personalized fitness journey 🤩.\n\nHere's a quick summary of what you shared 👇",
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Summary Cards
              _infoTile(
                icon: Icons.person_outline,
                label:
                    "User: $gender, $age yrs, ${weight.toStringAsFixed(1)} $weightUnit, $heightDisplay",
                context: context,
              ),
              const SizedBox(height: 12),
              _infoTile(
                icon: Icons.fitness_center_outlined,
                label: "Training: $goal, $trainingDays days/week",
                context: context,
              ),
              const SizedBox(height: 32),
              Text(
                "Sign up below to start your training",
                style: TextStyle(color: c.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 20),
              // Google Button
              _socialButton(
                label: "Continue with Google",
                icon: Icons.g_mobiledata,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Google Sign-In Placeholder")),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Email Button
              _emailButton(
                label: "Sign up with Email",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Divider with "or"
              Row(
                children: [
                  Expanded(child: Divider(color: c.surface)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("or", style: TextStyle(color: c.textMuted)),
                  ),
                  Expanded(child: Divider(color: c.surface)),
                ],
              ),
              const SizedBox(height: 20),
              // Log in button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Log in with existing account",
                  style: TextStyle(
                    color: AppTheme.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Terms and conditions
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "By continuing forward, you agree to Corely's\nPrivacy Policy and Terms & Conditions",
                  style: TextStyle(color: c.textPrimary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  // ── Info tile ─────────────────────────────────
  // Changed from static to instance method so BuildContext is available,
  // OR pass context explicitly as a parameter if keeping it static.
  static Widget _infoTile({
    required BuildContext context, // <-- added so we can read the theme
    required IconData icon,
    required String label,
  }) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border), // was empty → now c.border
      ),
      child: Row(
        children: [
          Icon(icon, color: c.accent), // was AppTheme.yellow → c.accent
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: c.textPrimary, // was isDarkMode ternary → token
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Social login button ───────────────────────
  // Intentionally always white — matches Google/Apple brand guidelines.
  // No theme dependency needed here.
  static Widget _socialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  // ── Email / primary CTA button ────────────────
  // Uses AppTheme.accent directly — always the brand colour,
  // same as FitAccentCard / the onboarding button.
  static Widget _emailButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor:
            AppTheme.accent, // was AppTheme.yellow → AppTheme.accent
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
