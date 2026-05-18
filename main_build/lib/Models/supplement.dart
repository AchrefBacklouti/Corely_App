class Supplement {
  final String id;
  final String name;
  final String category; // e.g., "Protein", "Creatine", "BCAA", "Vitamin"
  final String description;
  final String benefits; // Main benefits
  final String dosage; // Recommended dosage
  final String imageAsset;
  final double rating; // 1-5 stars
  final String flavor; // e.g., "Vanilla", "Chocolate", "Unflavored"

  const Supplement({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.benefits,
    required this.dosage,
    required this.imageAsset,
    required this.rating,
    required this.flavor,
  });
}

const List<Supplement> popularSupplements = [
  Supplement(
    id: 'sup_001',
    name: 'Whey Protein',
    category: 'Protein',
    description:
        'Fast-digesting protein powder derived from milk, ideal for post-workout recovery.',
    benefits:
        'Muscle recovery, strength gain, supports lean muscle mass development',
    dosage: '25-35g per serving, 1-3 times daily',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.8,
    flavor: 'Vanilla, Chocolate, Strawberry',
  ),
  Supplement(
    id: 'sup_002',
    name: 'Creatine Monohydrate',
    category: 'Strength',
    description:
        'Increases ATP production for enhanced strength and muscle gains.',
    benefits:
        'Increased strength, muscle endurance, improved athletic performance',
    dosage: '3-5g daily (optional loading phase: 20g split over 5 days)',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.7,
    flavor: 'Unflavored',
  ),
  Supplement(
    id: 'sup_003',
    name: 'BCAAs (Branched-Chain Amino Acids)',
    category: 'Amino Acids',
    description: 'Essential amino acids that support muscle protein synthesis.',
    benefits: 'Reduced muscle breakdown, faster recovery, improved focus',
    dosage: '5-10g per serving, 1-2 times daily',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.5,
    flavor: 'Tropical, Blue Raspberry, Lemon-Lime',
  ),
  Supplement(
    id: 'sup_004',
    name: 'Pre-Workout',
    category: 'Energy',
    description:
        'Boosts energy, focus, and endurance for intense training sessions.',
    benefits: 'Increased energy, improved focus, enhanced blood flow',
    dosage: '5-10g mixed with water, 20-30 minutes before workout',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.6,
    flavor: 'Fruit Punch, Green Apple, Watermelon',
  ),
  Supplement(
    id: 'sup_005',
    name: 'Omega-3 Fish Oil',
    category: 'Vitamin',
    description:
        'Essential fatty acids that support heart health and joint recovery.',
    benefits:
        'Joint health, cardiovascular support, reduced inflammation, brain function',
    dosage: '1-3g EPA/DHA daily, typically 2-3 capsules with meals',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.4,
    flavor: 'Capsule (lemon, orange options)',
  ),
  Supplement(
    id: 'sup_006',
    name: 'Multivitamin',
    category: 'Vitamin',
    description:
        'Complete micronutrient support for overall health and immunity.',
    benefits: 'Enhanced immunity, energy support, fills nutritional gaps',
    dosage: '1-2 tablets daily with food',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.3,
    flavor: 'Tablet',
  ),
  Supplement(
    id: 'sup_007',
    name: 'Caffeine Pills',
    category: 'Energy',
    description: 'Concentrated caffeine for quick energy boost and focus.',
    benefits: 'Increased alertness, improved performance, sustained energy',
    dosage: '100-200mg per dose, up to 2-3 times daily',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.5,
    flavor: 'Tablet',
  ),
  Supplement(
    id: 'sup_008',
    name: 'Casein Protein',
    category: 'Protein',
    description:
        'Slow-digesting protein, perfect for muscle preservation overnight.',
    benefits:
        'Sustained amino acid release, muscle recovery during sleep, sustained energy',
    dosage: '25-40g before bed',
    imageAsset: 'assets/img/logo_light.png',
    rating: 4.4,
    flavor: 'Vanilla, Chocolate, Cookies & Cream',
  ),
];
