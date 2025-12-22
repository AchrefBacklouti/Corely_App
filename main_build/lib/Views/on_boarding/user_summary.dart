import 'package:flutter/material.dart';
import 'package:main_build/Views/main_app/home_page.dart';
import 'package:main_build/Theme/app_theme.dart';

class UserSummary extends StatelessWidget {
  final String gender;
  final int age;
  final double weight;
  final int height;
  final String goal;
  final int trainingDays;
  final String weightUnit;
  final String heightUnit;

  const UserSummary({
    super.key,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.trainingDays,
    required this.weightUnit,
    required this.heightUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // Title
              const Text(
                "You’re all set up!!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Everything’s ready for your personalized fitness journey 🤩.\n\nHere’s a quick summary of what you shared 👇",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Cards
              _infoTile(
                icon: Icons.person_outline,
                label:
                    "User: $gender, $age yrs, ${weight.toStringAsFixed(1)} $weightUnit, $height"
                    "$heightUnit",
              ),
              const SizedBox(height: 12),
              _infoTile(
                icon: Icons.fitness_center_outlined,
                label: "Training: $goal, $trainingDays days/week",
              ),
              const SizedBox(height: 32),

              const Center(
                child: Text(
                  "Sign up below to start your training",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email Sign-Up Placeholder")),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Divider with “or”
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("or", style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 20),

              // Log in button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShellPage()),
                    );
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
              ),
              const Spacer(),

              // Terms and conditions
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "By continuing forward, you agree to Corely’s\nPrivacy Policy and Terms & Conditions",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _infoTile({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.yellow),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
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
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _emailButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: AppTheme.yellow,
        foregroundColor: Colors.black,
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
