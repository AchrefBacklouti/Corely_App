import 'package:flutter/material.dart';
import 'package:main_build/Models/exercise.dart';
import 'package:main_build/Theme/app_theme.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

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
          exercise.name,
          style: TextStyle(color: palette.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.gifUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  exercise.gifUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: palette.accent,
                      size: 42,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 220,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: palette.accent,
                  size: 42,
                ),
              ),
            const SizedBox(height: 18),
            Text(
              exercise.name,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _pill(context, 'Body part: ${exercise.bodyPart}'),
                _pill(context, 'Target: ${exercise.target}'),
                _pill(context, 'Equipment: ${exercise.equipment}'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Details",
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap Add on the previous screen to include this exercise in your plan.",
              style: TextStyle(color: palette.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    final theme = Theme.of(context);
    final palette = theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        text,
        style: TextStyle(color: palette.textSecondary, fontSize: 13),
      ),
    );
  }
}
