import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Theme/theme_scope.dart';
import 'package:main_build/Views/main_app/settings/about_settings.dart';
import 'package:main_build/Views/main_app/settings/account_settings.dart';
import 'package:main_build/Views/main_app/settings/notifications_settings.dart';
import 'package:main_build/Views/main_app/settings/privacy_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: c.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            // ── Content ─────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ThemeTile(isDark: isDark),
                    const SizedBox(height: 8),
                    _SettingTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsSettings(),
                        ),
                      ),
                    ),
                    _SettingTile(
                      icon: Icons.person,
                      title: 'Account',
                      subtitle: 'Manage your account information',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountSettings(),
                        ),
                      ),
                    ),
                    _SettingTile(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      subtitle: 'Control your privacy settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacySettings(),
                        ),
                      ),
                    ),
                    _SettingTile(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'Learn more about Corely',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutSettings(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Theme toggle tile
// ─────────────────────────────────────────────
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          _IconBox(icon: Icons.brightness_6),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  isDark ? 'Dark mode' : 'Light mode',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            activeThumbColor: Colors.black,
            activeTrackColor: c.accent,
            inactiveThumbColor: c.textMuted,
            inactiveTrackColor: c.border,
            onChanged: (_) => ThemeScope.of(context).toggleTheme(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Generic setting row tile
// ─────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              _IconBox(icon: icon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: c.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared icon box (accent tinted background)
// ─────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: c.accent, size: 22),
    );
  }
}
