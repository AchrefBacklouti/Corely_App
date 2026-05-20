import 'package:flutter/foundation.dart';
import 'package:main_build/Models/user_profile.dart';
import 'package:main_build/data/supabase_service.dart';

/// Global provider for managing user profile and onboarding data
class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Temporary onboarding data (before signup)
  String? _tempGender;
  int? _tempAge;
  double? _tempWeight;
  String? _tempHeight;
  String? _tempGoal;
  int? _tempTrainingDays;
  String? _tempWeightUnit;
  String? _tempHeightUnit;
  String? _tempBirthDateDisplay;
  String? _tempBirthDateIso;

  UserProvider._internal();

  static UserProvider get instance => _instance;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userProfile != null;
  bool get isProfileComplete => _userProfile?.isComplete ?? false;

  // Getters for temporary onboarding data
  String? get tempGender => _tempGender;
  int? get tempAge => _tempAge;
  double? get tempWeight => _tempWeight;
  String? get tempHeight => _tempHeight;
  String? get tempGoal => _tempGoal;
  int? get tempTrainingDays => _tempTrainingDays;
  String? get tempWeightUnit => _tempWeightUnit;
  String? get tempHeightUnit => _tempHeightUnit;
  String? get tempBirthDateDisplay => _tempBirthDateDisplay;
  String? get tempBirthDateIso => _tempBirthDateIso;

  /// Store temporary onboarding data (from CorelyOnboardingFlow)
  void setTemporaryOnboardingData({
    required String gender,
    required int age,
    required double weight,
    required String height,
    required String goal,
    required int trainingDays,
    required String weightUnit,
    required String heightUnit,
    required String birthDateDisplay,
    required String birthDateIso,
  }) {
    _tempGender = gender;
    _tempAge = age;
    _tempWeight = weight;
    _tempHeight = height;
    _tempGoal = goal;
    _tempTrainingDays = trainingDays;
    _tempWeightUnit = weightUnit;
    _tempHeightUnit = heightUnit;
    _tempBirthDateDisplay = birthDateDisplay;
    _tempBirthDateIso = birthDateIso;
    debugPrint(
      'UserProvider: Stored temporary onboarding data - $gender, $age, ${weight}$weightUnit',
    );
  }

  /// Load current user's profile from Supabase
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await SupabaseService.getLocalUserProfile();
      _userProfile ??= await SupabaseService.getOrCreateCurrentUserProfile();
      if (_userProfile == null) {
        _errorMessage = 'Could not load user profile';
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      debugPrint('UserProvider.loadUserProfile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile with new data
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    double? weight,
    double? height,
    String? goal,
    int? trainingDaysPerWeek,
    String? weightUnit,
    String? heightUnit,
  }) async {
    if (_userProfile == null) {
      _errorMessage = 'No user profile loaded';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await SupabaseService.updateUserProfile(
        _userProfile!.userId,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        age: age,
        weight: weight,
        height: height,
        goal: goal,
        trainingDaysPerWeek: trainingDaysPerWeek,
        weightUnit: weightUnit,
        heightUnit: heightUnit,
      );

      if (updated != null) {
        _userProfile = updated;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('UserProvider.updateUserProfile: $e');
      return false;
    }
  }

  /// Clear user profile (on logout)
  void clearUserProfile() {
    _userProfile = null;
    _errorMessage = null;
    _isLoading = false;
    SupabaseService.clearLocalUserProfile();
    notifyListeners();
  }

  /// Clear temporary onboarding data
  void clearTemporaryData() {
    _tempGender = null;
    _tempAge = null;
    _tempWeight = null;
    _tempHeight = null;
    _tempGoal = null;
    _tempTrainingDays = null;
    _tempWeightUnit = null;
    _tempHeightUnit = null;
    _tempBirthDateDisplay = null;
    _tempBirthDateIso = null;
  }

  /// Set user profile directly
  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    _errorMessage = null;
    _isLoading = false;
    if (profile != null) {
      SupabaseService.saveLocalUserProfile(profile);
    }
    notifyListeners();
  }
}
