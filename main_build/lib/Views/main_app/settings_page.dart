import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/logo.png', width: 75),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          children: [
            // ------------------------------------------------
            // NOTIFICATION (WITH SWITCH)
            // ------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1A1B1F),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white70),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Notification",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Switch(
                    value: _notifications,
                    activeThumbColor: Colors.yellow,
                    inactiveThumbColor: Colors.white54,
                    inactiveTrackColor: Colors.white24,
                    onChanged: (v) {
                      setState(() {
                        _notifications = v;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // NORMAL SETTINGS ITEMS
            // ------------------------------------------------
            _settingsItem(Icons.dark_mode_outlined, "Dark Mode"),
            _settingsItem(Icons.star_border, "Rate App"),
            _settingsItem(Icons.share_outlined, "Share App"),
            _settingsItem(Icons.lock_outline, "Privacy Policy"),
            _settingsItem(Icons.description_outlined, "Terms and Conditions"),
            _settingsItem(Icons.cookie_outlined, "Cookies Policy"),
            _settingsItem(Icons.email_outlined, "Contact"),
            _settingsItem(Icons.feedback_outlined, "Feedback"),

            const SizedBox(height: 20),

            // ------------------------------------------------
            // LOGOUT BUTTON
            // ------------------------------------------------
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 16),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // REUSABLE SETTINGS ITEM COMPONENT
  // ------------------------------------------------
  Widget _settingsItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1B1F),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
