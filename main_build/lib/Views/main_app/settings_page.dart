import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'settings/notifications_settings.dart';
import 'settings/account_settings.dart';
import 'settings/privacy_settings.dart';
import 'settings/about_settings.dart';
import 'package:main_build/Theme/theme_scope.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Appearance / Theme toggle
                    _buildThemeTile(context, isDarkMode),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      context,
                      Icons.notifications,
                      "Notifications",
                      "Manage notification preferences",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsSettings(),
                        ),
                      ),
                      isDarkMode,
                    ),
                    _buildSettingTile(
                      context,
                      Icons.person,
                      "Account",
                      "Manage your account information",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountSettings(),
                        ),
                      ),
                      isDarkMode,
                    ),
                    _buildSettingTile(
                      context,
                      Icons.security,
                      "Privacy & Security",
                      "Control your privacy settings",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacySettings(),
                        ),
                      ),
                      isDarkMode,
                    ),
                    _buildSettingTile(
                      context,
                      Icons.info,
                      "About",
                      "Learn more about Corely",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutSettings(),
                        ),
                      ),
                      isDarkMode,
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

  Widget _buildThemeTile(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.brightness_6,
              color: AppTheme.yellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDarkMode ? 'Dark mode' : 'Light mode',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            activeThumbColor: Colors.black,
            activeTrackColor: AppTheme.yellow,
            onChanged: (_) => ThemeScope.of(context).toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkSurface : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.yellow, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
