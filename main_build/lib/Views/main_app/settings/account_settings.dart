import 'package:flutter/material.dart';
import 'package:main_build/Controllers/user_provider.dart';
import 'package:main_build/Theme/app_theme.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _goalController = TextEditingController();
  final _trainingDaysController = TextEditingController();

  String _gender = 'male';
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  bool _didSeed = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    _trainingDaysController.dispose();
    super.dispose();
  }

  void _seedFromProfile() {
    final profile = UserProvider.instance.userProfile;
    if (profile == null || _didSeed) return;

    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toStringAsFixed(1) ?? '';
    _heightController.text = profile.height?.toStringAsFixed(1) ?? '';
    _goalController.text = profile.goal ?? '';
    _trainingDaysController.text =
        profile.trainingDaysPerWeek?.toString() ?? '';
    _gender = profile.gender ?? _gender;
    _weightUnit = profile.weightUnit ?? _weightUnit;
    _heightUnit = profile.heightUnit ?? _heightUnit;
    _didSeed = true;
  }

  Future<void> _saveChanges() async {
    final age = int.tryParse(_ageController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final trainingDays = int.tryParse(_trainingDaysController.text.trim());

    setState(() => _isSaving = true);
    final success = await UserProvider.instance.updateUserProfile(
      firstName: _firstNameController.text.trim().isEmpty
          ? null
          : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      gender: _gender,
      age: age,
      weight: weight,
      height: height,
      goal: _goalController.text.trim().isEmpty
          ? null
          : _goalController.text.trim(),
      trainingDaysPerWeek: trainingDays,
      weightUnit: _weightUnit,
      heightUnit: _heightUnit,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully.'
              : 'Could not update profile.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    _seedFromProfile();
    final profile = UserProvider.instance.userProfile;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Account', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: AnimatedBuilder(
        animation: UserProvider.instance,
        builder: (context, _) {
          final currentProfile = UserProvider.instance.userProfile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _InfoItem(
                  label: 'Email',
                  value: currentProfile?.email ?? 'Unknown',
                ),
                _InfoItem(
                  label: 'Member Since',
                  value:
                      currentProfile?.createdAt
                          .toLocal()
                          .toString()
                          .split('.')
                          .first ??
                      'Unknown',
                ),
                const SizedBox(height: 24),
                Text(
                  'Update Profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _Field(controller: _firstNameController, label: 'First name'),
                const SizedBox(height: 12),
                _Field(controller: _lastNameController, label: 'Last name'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: _inputDecoration(context, 'Gender'),
                  dropdownColor: c.surface,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _gender = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _ageController,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        controller: _weightController,
                        label: 'Weight',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _heightController,
                        label: 'Height',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _weightUnit,
                        decoration: _inputDecoration(context, 'Weight unit'),
                        dropdownColor: c.surface,
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('kg')),
                          DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _weightUnit = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _heightUnit,
                        decoration: _inputDecoration(context, 'Height unit'),
                        dropdownColor: c.surface,
                        items: const [
                          DropdownMenuItem(value: 'cm', child: Text('cm')),
                          DropdownMenuItem(value: 'ft', child: Text('ft')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _heightUnit = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        controller: _trainingDaysController,
                        label: 'Training days/week',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _goalController,
                  label: 'Main goal',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save changes'),
                  ),
                ),
                if (profile == null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'No profile loaded yet. Sign in again if this screen is empty.',
                    style: TextStyle(color: c.textSecondary, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Account Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset coming soon')),
                  ),
                  child: const Text('Change Password'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final c = context.colors;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: c.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.accent, width: 1.4),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.accent, width: 1.4),
        ),
      ),
      style: TextStyle(color: c.textPrimary),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(color: c.border, height: 24),
        ],
      ),
    );
  }
}
