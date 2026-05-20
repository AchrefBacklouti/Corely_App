## Complete User Profile & Authentication Integration

### What's Been Set Up

✅ **Supabase Database:**
- `user_profiles` table linked to `auth.users` via `user_id`
- Stores: gender, age, weight, height, goal, training_days_per_week, weight_unit, height_unit
- Row-level security (RLS) - users can only see their own data

✅ **Flutter Models:**
- `Models/user_profile.dart` - UserProfile model with JSON serialization

✅ **Backend Service:**
- `data/supabase_service.dart` - Methods to:
  - `createUserProfile()` - Create new profile after signup
  - `getUserProfile()` - Fetch profile by user ID
  - `updateUserProfile()` - Update profile data
  - `getCurrentUserProfile()` - Get logged-in user's profile

✅ **Global State Management:**
- `Controllers/user_provider.dart` - UserProvider singleton:
  - Stores current user profile globally
  - Stores temporary onboarding data before signup
  - Methods: `loadUserProfile()`, `updateUserProfile()`, `setTemporaryOnboardingData()`

✅ **Updated Views:**
- `Views/auth/signup_page.dart` - Creates profile with onboarding data after signup
- `Views/auth/login_page.dart` - Loads user profile after login
- `Views/on_boarding/user_summary.dart` - Stores onboarding data in UserProvider before signup

---

## Data Flow

### 1. **User Signup with Onboarding**

```
CorelyOnboardingFlow (collect data)
    ↓
UserSummary (show summary)
    ↓ "Sign up with Email" button
    ↓ UserProvider.setTemporaryOnboardingData()
    ↓
SignUpPage (email/password)
    ↓ Create auth account
    ↓
SupabaseService.createUserProfile() 
    ↓ (with all onboarding data)
    ↓
user_profiles table
    ↓
UserProvider.setUserProfile()
    ↓
Home Screen ✅
```

### 2. **User Login**

```
LoginPage (email/password)
    ↓ Authenticate
    ↓
SupabaseService.getCurrentUserProfile()
    ↓ Fetch from user_profiles
    ↓
UserProvider.setUserProfile()
    ↓
Home Screen ✅
```

### 3. **Access User Data Anywhere**

```dart
// In any widget, get the current user profile:
UserProvider.instance.userProfile?.gender
UserProvider.instance.userProfile?.age
UserProvider.instance.userProfile?.weight
UserProvider.instance.userProfile?.height
UserProvider.instance.userProfile?.goal
UserProvider.instance.userProfile?.trainingDaysPerWeek
```

---

## How to Use in Your App

### After Login/Signup, Show User Info:

```dart
// In home_page.dart or any other screen
class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = UserProvider.instance.userProfile;
    
    if (user == null) {
      return Text('Loading...');
    }
    
    return Column(
      children: [
        Text('Welcome, ${user.fullName}!'),
        Text('Age: ${user.age}'),
        Text('Weight: ${user.weight} ${user.weightUnit}'),
        Text('Goal: ${user.goal}'),
        Text('Training Days: ${user.trainingDaysPerWeek}/week'),
      ],
    );
  }
}
```

### Update Profile After Changes:

```dart
// When user updates their profile (e.g., after completing a workout):
await UserProvider.instance.updateUserProfile(
  weight: 72.5,  // Updated weight
  age: 26,       // Updated age
  goal: 'Lose fat',  // Changed goal
);
```

### Check if Profile is Complete:

```dart
if (UserProvider.instance.isProfileComplete) {
  // Show main app
} else {
  // Show onboarding
}
```

---

## Database Schema

```sql
CREATE TABLE user_profiles (
  id uuid PRIMARY KEY,
  user_id uuid UNIQUE NOT NULL (links to auth.users),
  email text NOT NULL,
  first_name text,
  last_name text,
  gender text,
  age integer,
  weight numeric,
  height numeric,
  goal text,
  training_days_per_week integer,
  weight_unit text ('kg' or 'lbs'),
  height_unit text ('cm' or 'ft-in'),
  created_at timestamp,
  updated_at timestamp
);
```

---

## What Data Gets Saved

### At Signup:
✅ user_id (from auth.users)  
✅ email  
✅ gender (from onboarding)  
✅ age (from onboarding)  
✅ weight (from onboarding)  
✅ height (from onboarding)  
✅ goal (from onboarding)  
✅ training_days_per_week (from onboarding)  
✅ weight_unit (from onboarding)  
✅ height_unit (from onboarding)  
✅ created_at (auto)  
✅ updated_at (auto)  

### When User Logs In:
✅ All profile data is fetched and loaded into `UserProvider`

### Can Be Updated Later:
- Any of the above fields can be updated via `UserProvider.updateUserProfile()`

---

## Testing

### Test Flow:
1. Run the app
2. Go through onboarding (CorelyOnboardingFlow)
3. Click "Sign up with Email"
4. Enter email and password
5. Should see home screen with user data
6. Log out and log back in
7. User data should load automatically

### Check Supabase:
Go to Supabase Dashboard → SQL Editor → Run:
```sql
SELECT * FROM user_profiles;
```

You should see rows for each signed-up user with all their data.

---

## Files Modified/Created

✅ Created: `lib/Models/user_profile.dart`
✅ Created: `lib/Controllers/user_provider.dart`
✅ Updated: `lib/data/supabase_service.dart` - Added user profile methods
✅ Updated: `lib/Views/auth/signup_page.dart` - Create profile on signup
✅ Updated: `lib/Views/auth/login_page.dart` - Load profile on login
✅ Updated: `lib/Views/on_boarding/user_summary.dart` - Pass data to UserProvider

---

## Next Steps (Optional)

1. Add a settings screen to allow users to update their profile
2. Add profile picture upload
3. Add nutrition/workout history tracking to user_profiles
4. Create analytics based on user profile data
5. Add badges/achievements tracking
