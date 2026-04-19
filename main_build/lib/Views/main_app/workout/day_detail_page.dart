import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

class DayDetailPage extends StatelessWidget {
  final int dayNumber;
  final String planTitle;

  const DayDetailPage({
    super.key,
    required this.dayNumber,
    required this.planTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text(
          '$planTitle - Day $dayNumber',
          style: TextStyle(color: palette.textPrimary),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.accent, width: 3),
                ),
                child: Center(
                  child: Icon(Icons.play_arrow, color: palette.accent, size: 50),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Day $dayNumber Workout',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Workout details and exercises will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Start workout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Starting workout...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Workout',
                    style: TextStyle(
                      color: palette.background,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
