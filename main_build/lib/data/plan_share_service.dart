import 'dart:convert';
import 'package:main_build/data/workout_plans.dart';

class PlanShareService {
  /// Convert plan to JSON string for sharing
  static String exportPlanAsJson(WorkoutPlan plan) {
    final jsonMap = plan.toJson();
    return jsonEncode(jsonMap);
  }

  /// Compress plan to a shorter shareable code
  static String generateShareCode(WorkoutPlan plan) {
    final jsonString = exportPlanAsJson(plan);
    // Convert to base64 for URL-safe sharing
    return base64Url.encode(utf8.encode(jsonString)).replaceAll('=', '');
  }

  /// Decode share code back to plan
  static WorkoutPlan? decodeShareCode(String code) {
    try {
      // Add padding back if needed
      final padded = code.padRight(
        code.length + (4 - code.length % 4) % 4,
        '=',
      );
      final jsonString = utf8.decode(base64Url.decode(padded));
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return WorkoutPlan.fromJson(jsonMap);
    } catch (e) {
      print('Error decoding share code: $e');
      return null;
    }
  }

  /// Format plan info for text sharing
  static String generateShareText(WorkoutPlan plan) {
    final buffer = StringBuffer();
    buffer.writeln('💪 ${plan.title}');
    buffer.writeln('');
    buffer.writeln('📅 Schedule:');
    for (int i = 0; i < plan.selectedDays.length; i++) {
      final dayName = i < plan.dayNames.length
          ? plan.dayNames[i]
          : plan.selectedDays[i];
      buffer.writeln('  • ${plan.selectedDays[i]}: $dayName');
    }
    buffer.writeln('');
    buffer.writeln('💪 ${plan.exercises}');
    buffer.writeln('⏱️  ${plan.duration}');
    buffer.writeln('');
    buffer.writeln('📱 Share Code: ${generateShareCode(plan)}');
    return buffer.toString();
  }
}
