import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  bool _workoutReminders = true;
  bool _mealsReminders = true;
  bool _progressUpdates = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _NotifTile(
              title: 'Workout Reminders',
              subtitle: 'Get reminded about your workouts',
              value: _workoutReminders,
              onChanged: (v) => setState(() => _workoutReminders = v),
            ),
            _NotifTile(
              title: 'Meals Reminders',
              subtitle: 'Get reminded to log your meals',
              value: _mealsReminders,
              onChanged: (v) => setState(() => _mealsReminders = v),
            ),
            _NotifTile(
              title: 'Progress Updates',
              subtitle: 'Weekly progress summaries',
              value: _progressUpdates,
              onChanged: (v) => setState(() => _progressUpdates = v),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: c.textPrimary),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      activeColor: Colors.black,
      activeTrackColor: c.accent,
      inactiveThumbColor: c.textMuted,
      inactiveTrackColor: c.border,
      onChanged: onChanged,
    );
  }
}
