/**
 * EXAMPLE: How a Workout Plan is Saved in Hive (JSON format)
 * 
 * When you create a plan with exercises, here's what gets stored:
 */

// SIMPLE EXAMPLE (2-day plan with exercises)
{
  "id": "1705954234567",
  "title": "Push Day",
  "duration": "10 mins",
  "exercises": "4 exercises",
  "imageAsset": "assets/img/logo_light.png",
  "difficulty": 1,
  "dayExercises": [
    // DAY 1 EXERCISES
    [
      {
        "id": "0001",
        "name": "Barbell Bench Press",
        "category": "chest",
        "equipment": "barbell",
        "force": "push",
        "level": "intermediate",
        "mechanic": "compound",
        "primaryMuscles": ["chest"],
        "secondaryMuscles": ["triceps", "shoulders"],
        "instructions": [
          "Lie on a flat bench with feet on the floor",
          "Grip the barbell slightly wider than shoulder width",
          "Lower the bar to your chest",
          "Press the bar back up"
        ],
        "images": ["barbell-bench-press.jpg"]
      },
      {
        "id": "0002",
        "name": "Dumbbell Flyes",
        "category": "chest",
        "equipment": "dumbbell",
        "force": "push",
        "level": "beginner",
        "mechanic": "isolation",
        "primaryMuscles": ["chest"],
        "secondaryMuscles": [],
        "instructions": [
          "Lie on a bench with dumbbells above your chest",
          "Lower dumbbells in an arc motion",
          "Feel the stretch in your chest",
          "Return to starting position"
        ],
        "images": ["dumbbell-fly.jpg"]
      }
    ],
    // DAY 2 EXERCISES
    [
      {
        "id": "0045",
        "name": "Tricep Dips",
        "category": "triceps",
        "equipment": "body weight",
        "force": "push",
        "level": "intermediate",
        "mechanic": "compound",
        "primaryMuscles": ["triceps"],
        "secondaryMuscles": ["chest", "shoulders"],
        "instructions": [
          "Position yourself on parallel bars",
          "Lower your body by bending elbows",
          "Go down until elbows are at 90 degrees",
          "Push back up to starting position"
        ],
        "images": ["tricep-dips.jpg"]
      }
    ]
  ],
  "createdAt": "2026-01-22T14:30:34.567Z"
}

/**
 * NESTED STRUCTURE BREAKDOWN:
 * 
 * Plan Level:
 * └─ id: unique identifier for the plan
 * └─ title: plan name (e.g., "Push Day")
 * └─ duration: estimated time (calculated as days * 5 mins)
 * └─ exercises: summary text (e.g., "4 exercises")
 * └─ difficulty: 1-5 scale
 * └─ dayExercises: ARRAY OF DAYS
 *    └─ [0] = Day 1 exercises (ARRAY)
 *    │  └─ [0] = Exercise 1 object
 *    │  │  ├─ id, name, category, equipment
 *    │  │  ├─ force, level, mechanic
 *    │  │  ├─ primaryMuscles (array of strings)
 *    │  │  ├─ secondaryMuscles (array of strings)
 *    │  │  ├─ instructions (array of strings)
 *    │  │  └─ images (array of file names)
 *    │  └─ [1] = Exercise 2 object
 *    │  └─ [2] = Exercise 3 object
 *    │
 *    └─ [1] = Day 2 exercises (ARRAY)
 *       └─ [0] = Exercise 1 object
 *       └─ [1] = Exercise 2 object
 *
 * HOW IT'S SAVED:
 * └─ Plans are stored in Hive box: "custom_plans"
 * └─ Each plan is a Map stored as a Hive item
 * └─ Can have multiple plans in the same box
 * └─ Retrieved by index (0, 1, 2, etc.)
 *
 * WHEN YOU EDIT:
 * └─ The entire plan is fetched with all exercises
 * └─ You modify exercises in the UI
 * └─ Old plan is deleted from Hive
 * └─ New plan (with updated exercises) is saved
 */
