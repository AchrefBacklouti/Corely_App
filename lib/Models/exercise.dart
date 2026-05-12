class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;
  final String? gifUrl;
  final String? force;
  final String? level;
  final String? mechanic;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    this.gifUrl,
    this.force,
    this.level,
    this.mechanic,
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];
    String? imageUrl;
    if (images.isNotEmpty) {
      final firstImage = images[0].toString();
      if (firstImage.startsWith('http://') ||
          firstImage.startsWith('https://')) {
        imageUrl = firstImage;
      } else {
        imageUrl =
            'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$firstImage';
      }
    }

    final primaryMuscles = (json['primaryMuscles'] as List<dynamic>? ?? [])
        .map((m) => m.toString())
        .toList();

    final secondaryMuscles = (json['secondaryMuscles'] as List<dynamic>? ?? [])
        .map((m) => m.toString())
        .toList();

    final instructions = (json['instructions'] as List<dynamic>? ?? [])
        .map((i) => i.toString())
        .toList();

    return Exercise(
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String? ?? '').trim(),
      bodyPart: (json['category'] as String? ?? 'strength').trim(),
      target: primaryMuscles.isNotEmpty ? primaryMuscles.join(', ') : 'General',
      equipment: (json['equipment'] as String? ?? 'body only').trim(),
      gifUrl: imageUrl,
      force: (json['force'] as String?)?.trim(),
      level: (json['level'] as String?)?.trim(),
      mechanic: (json['mechanic'] as String?)?.trim(),
      secondaryMuscles: secondaryMuscles,
      instructions: instructions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': bodyPart,
      'primaryMuscles': target.split(', '),
      'equipment': equipment,
      'images': gifUrl != null ? [gifUrl!.split('/').last] : [],
      'force': force,
      'level': level,
      'mechanic': mechanic,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }
}
