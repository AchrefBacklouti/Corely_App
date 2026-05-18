# Corely Fitness App - AI Coding Guidelines

## Project Overview
Corely is a multi-platform Flutter fitness application (iOS, Android, Linux, macOS, Windows) for tracking workouts, nutrition, and progress. The app uses a stateful UI pattern with separate views for Home, Workout, Stats, and Nutrition tracking.

## Architecture & Key Patterns

### Directory Structure
- **`lib/Views/`** - UI screens organized by feature (auth/, main_app/, on_boarding/, SharedWidgets/)
- **`lib/Controllers/`** - Currently empty; future state management layer
- **`lib/Models/`** - Data models (e.g., `HomeSummaryModel`, `WorkoutDay`, `DailyNutrition`)
- **`lib/Theme/`** - Centralized theming via `AppTheme` (dark-first design: `#0D1117` dark background, `#FFFF00` primary yellow)
- **`main_build/`** - Primary Flutter project root with pubspec.yaml

### UI Architecture Pattern
The app uses **component-based stateful widgets** without a state management framework:
- **`MainShellPage`** - Container shell managing bottom nav index across 4 pages
- **Page Content Classes** (HomePageContent, WorkoutPageContent, etc.) - Stateless components rendering tabbed content
- **Sub-widgets** - Private helper widgets (prefixed with `_`) for cards, sections, animations
- **AnimatedBuilder** - Used for progress bars and animations (see `StepsCard` with AnimationController)

**Example pattern** from `home_page.dart`:
```dart
class _StepsCardState extends State<StepsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  void _setupAnimation() { /* clamp progress 0-1 */ }
  // AnimatedBuilder for smooth rendering
}
```

### Theme System
All colors defined in `AppTheme` - **never hardcode colors**:
- **Dark Mode (default)**: `darkBackground: #0D1117`, `darkSurface: #101318`
- **Primary**: `yellow: #FFFF00`
- **Text**: White/White70 for contrast
- **Button styling**: 12px borderRadius, yellow background with black text

## Key Development Patterns

### Navigation
- Routes defined in `main.dart`: `/` (LoadingPage), `/welcome`, `/login`
- Named route navigation for auth flow, MaterialPageRoute push for feature navigation
- Example: `Navigator.pushReplacementNamed(context, '/welcome')`

### Component Composition
Break views into small, focused stateless widgets:
```dart
class HomePageContent extends StatelessWidget { // parent
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _GreetingText(),     // private widget
      _StatsSection(),     // private widget
      _TodayFocus(),       // reusable components
    ]);
  }
}
```

### Forms & User Input
- **UnitToggle widget** (`SharedWidgets/toggle-Unit.dart`) - custom toggle for unit selection (kg/lbs, cm/ft)
- **PickerWidget** (`SharedWidgets/build_piker.dart`) - picker for height, weight, age
- **OnboardingFlow** - Multi-step form collecting user goals, gender, measurements before showing main app

### Data Models
Models define domain data (minimal logic):
```dart
class HomeSummaryModel {
  final int stepsToday;
  final double caloriesBurnedToday;
  final DailyNutrition? todayNutrition;
  final WorkoutDay? todayWorkout;
  // constructors only
}
```

## Workflow & Build Commands

### Development
```bash
cd main_build
flutter pub get              # Install dependencies
flutter run -d <device>      # Run on connected device/emulator
flutter run --release        # Production build
```

### Testing
```bash
flutter test                 # Run tests in test/widget_test.dart
```

### Dependencies (pubspec.yaml)
- **UI**: flutter_svg (for SVG assets), cupertino_icons
- **Dev**: flutter_lints (analysis_options.yaml enforces rules)
- **Fonts**: Roboto, Livvic, Linden_hill (configured in pubspec.yaml)

### Assets
All assets in `assets/` and declared in pubspec.yaml:
- Icons: SVGs in `assets/icons/` (e.g., `assets/icons/settings.svg`)
- Images: PNGs in root (logo.png, shoe.png)
- Anatomy diagrams: `assets/anatomy/front.png`, `back.png`
- Exercise icons: `assets/ex_icons/decline.png` (referenced in workout_page)

## Code Conventions

### Naming & Structure
1. **Files**: snake_case (home_page.dart, user_summary.dart)
2. **Classes**: PascalCase (MainShellPage, HomePageContent)
3. **Private components**: prefix with `_` (\_GreetingText, \_StatsSection)
4. **Constants**: AppTheme static properties

### Widget Guidelines
- **Use const constructors** where possible (improves performance)
- **Avoid widget rebuilds**: wrap expensive calculations in methods returning Widgets
- **SafeArea**: Always use for pages to respect system status/nav bars
- **SingleChildScrollView**: Wrap page content for overflow handling

### Color Usage
```dart
// ✅ GOOD
color: AppTheme.yellow        // from theme
backgroundColor: AppTheme.darkBackground

// ❌ AVOID
color: Color(0xFFFFD600)      // hardcoded
backgroundColor: Colors.black12
```

### Spacing & Layout
- Use `SizedBox` for consistent spacing (12, 14, 16, 18, 22, 24px patterns observed)
- Use `EdgeInsets.symmetric()` for horizontal/vertical padding
- BorderRadius: 12-14px for cards (observed standard)

## Feature-Specific Patterns

### Home Page
- **Greeting + Stats Row**: User name, steps, calories
- **Cards Section**: Streak card, quick access, achievements
- **Tab Navigation**: 4-page IndexedStack (Home, Workout, Stats, Nutrition)
- **Animations**: FadeTransition in loading_page, AnimatedBuilder for progress

### Workout Page
- Displays workout split (upper/lower), exercises with icons
- Exercise list shows reps/weight, muscle groups
- Filter tags (duration, equipment)
- Options menu for workout management

### Stats Page
- Bodyweight/weight progress (placeholder graphs)
- Recovery overview with muscle development anatomy images
- Fitness overview comparison metrics

### Nutrition Page
- Macro donut chart (protein/carbs/fats)
- Daily intake vs goals (kcal tracking)
- Recipe browsing section
- Unit toggle for gram vs other units

### Onboarding
- Multi-step form collecting: gender, age, weight, height, goals, training days
- Builds `UserSummary` and navigates to main app
- Custom unit selection (kg/lbs, cm/ft-in)

## Testing Conventions
- Tests in `test/widget_test.dart`
- Widget tests verify UI behavior (e.g., navigation, animation completion)
- Mock user interactions with `tester.tap()`, `tester.pumpWidget()`

## Common Gotchas & Best Practices

1. **Dispose Controllers**: Always dispose AnimationControllers in StatefulWidget.dispose()
   ```dart
   @override void dispose() { _controller.dispose(); super.dispose(); }
   ```

2. **Check Context Validity**: Before using context in async callbacks
   ```dart
   Future.delayed(..., () { if (!mounted) return; Navigator.pop(context); });
   ```

3. **Asset Declarations**: All assets must be listed in pubspec.yaml before use

4. **Font Family**: Use `fontFamily: 'Roboto'` or `'Livvic'` (defined in pubspec.yaml)

5. **Dark Mode Default**: ThemeMode is set to dark - test light mode behaviors explicitly

## File Examples to Reference
- **Routing & Animation**: [lib/Views/auth/loading_page.dart](lib/Views/auth/loading_page.dart) - FadeTransition, navigation timing
- **Multi-page Shell**: [lib/Views/main_app/home_page.dart](lib/Views/main_app/home_page.dart) - IndexedStack pattern, nested widgets
- **Forms**: [lib/Views/on_boarding/on_boarding.dart](lib/Views/on_boarding/on_boarding.dart) - Multi-step data collection
- **Custom Widgets**: [lib/Views/SharedWidgets/toggle-Unit.dart](lib/Views/SharedWidgets/toggle-Unit.dart) - Reusable component
- **Theme**: [lib/Theme/app_theme.dart](lib/Theme/app_theme.dart) - Centralized design system

## Architecture Notes for Future Development
- **State Management**: Controllers/ directory exists but unused - candidate for Provider/Riverpod when data complexity grows
- **API Integration**: Currently no backend calls visible; when adding, follow Model pattern and inject into Controllers
- **Data Persistence**: No local storage visible; consider Hive/SQLite for offline capability
