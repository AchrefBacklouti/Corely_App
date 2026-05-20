/// User profile model - stores all user data from signup and onboarding
class UserProfile {
  final String userId; // Supabase auth user ID
  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final int? age;
  final double? weight;
  final double? height;
  final String? goal;
  final int? trainingDaysPerWeek;
  final String? weightUnit; // 'kg' or 'lbs'
  final String? heightUnit; // 'cm' or 'ft-in'
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.goal,
    this.trainingDaysPerWeek,
    this.weightUnit,
    this.heightUnit,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
      'training_days_per_week': trainingDaysPerWeek,
      'weight_unit': weightUnit,
      'height_unit': heightUnit,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (Supabase response)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      goal: json['goal'] as String?,
      trainingDaysPerWeek: json['training_days_per_week'] as int?,
      weightUnit: json['weight_unit'] as String?,
      heightUnit: json['height_unit'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Copy with updates
  UserProfile copyWith({
    String? userId,
    String? email,
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
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'User';
  }

  /// Check if profile is complete (all onboarding data filled)
  bool get isComplete =>
      gender != null &&
      age != null &&
      weight != null &&
      height != null &&
      goal != null &&
      trainingDaysPerWeek != null;
}
