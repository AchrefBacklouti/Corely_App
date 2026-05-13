import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

class PrivacySettings extends StatelessWidget {
  const PrivacySettings({super.key});

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
          'Privacy & Security',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const _PrivacyRow(title: 'Profile Visibility', value: 'Public'),
            const _PrivacyRow(title: 'Data Collection', value: 'Limited'),
            const _PrivacyRow(title: 'Third-party Apps', value: 'Disabled'),
            const SizedBox(height: 24),
            Text('Security', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const _PrivacyRow(
              title: 'Two-Factor Authentication',
              value: 'Not enabled',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2FA setup coming soon')),
              ),
              icon: const Icon(Icons.security),
              label: const Text('Enable 2FA'),
              // Inherits backgroundColor: accent, foregroundColor: black
              // from AppTheme ElevatedButtonThemeData — no overrides needed.
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
