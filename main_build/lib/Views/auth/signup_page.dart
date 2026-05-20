import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:main_build/data/supabase_service.dart';
import 'package:main_build/Controllers/user_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildAuthMetadata(UserProvider userProvider) {
    return {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'gender': userProvider.tempGender,
      'age': userProvider.tempAge,
      'weight': userProvider.tempWeight,
      'height_display': userProvider.tempHeight,
      'goal': userProvider.tempGoal,
      'training_days_per_week': userProvider.tempTrainingDays,
      'weight_unit': userProvider.tempWeightUnit,
      'height_unit': userProvider.tempHeightUnit,
      'date_of_birth': userProvider.tempBirthDateIso,
      'birth_date_display': userProvider.tempBirthDateDisplay,
    };
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final userProvider = UserProvider.instance;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.length < 6) {
      setState(() {
        _errorMessage =
            'Enter first name, last name, a valid email, and a password (min 6 chars).';
      });
      return;
    }

    if (userProvider.tempWeightUnit == null ||
        userProvider.tempHeightUnit == null) {
      setState(() {
        _errorMessage =
            'Complete the onboarding steps first so weight and height units are saved.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final metadata = _buildAuthMetadata(userProvider);

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      // If a session is returned the user is signed in immediately
      if (_supabase.auth.currentSession != null && response.user != null) {
        // Get temporary onboarding data from UserProvider
        // Parse height string to get numeric value
        double? heightValue;
        if (userProvider.tempHeight != null) {
          if (userProvider.tempHeightUnit == 'ft') {
            // Parse "5ft 9in" format
            final parts = userProvider.tempHeight!.split('ft');
            if (parts.isNotEmpty) {
              heightValue = double.tryParse(parts[0].trim());
            }
          } else {
            // Parse "175cm" format
            final parts = userProvider.tempHeight!.split('cm');
            if (parts.isNotEmpty) {
              heightValue = double.tryParse(parts[0].trim());
            }
          }
        }

        // Create user profile with onboarding data
        final profile = await SupabaseService.createUserProfile(
          response.user!.id,
          email,
          firstName: firstName,
          lastName: lastName,
          gender: userProvider.tempGender,
          age: userProvider.tempAge,
          weight: userProvider.tempWeight,
          height: heightValue,
          goal: userProvider.tempGoal,
          trainingDaysPerWeek: userProvider.tempTrainingDays,
          weightUnit: userProvider.tempWeightUnit,
          heightUnit: userProvider.tempHeightUnit,
        );

        // Load profile into global provider
        if (profile != null) {
          UserProvider.instance.setUserProfile(profile);
          // Clear temporary data after using it
          userProvider.clearTemporaryData();
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      // Otherwise the user likely needs to confirm their email
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email to confirm your account.'),
        ),
      );
      Navigator.pushReplacementNamed(context, '/welcome');
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Sign up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        title: const Text('Sign up'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'First name',
                  filled: true,
                  fillColor: palette.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Last name',
                  filled: true,
                  fillColor: palette.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: palette.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password (min 6 chars)',
                  filled: true,
                  fillColor: palette.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (UserProvider.instance.tempWeightUnit != null ||
                  UserProvider.instance.tempHeightUnit != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  child: Text(
                    'Saved from onboarding: ${UserProvider.instance.tempWeight ?? '-'} ${UserProvider.instance.tempWeightUnit ?? ''}, ${UserProvider.instance.tempHeight ?? '-'} ${UserProvider.instance.tempHeightUnit ?? ''}, ${UserProvider.instance.tempGoal ?? '-'}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create account'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: Text(
                  'Have an account? Log in',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
