# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**FishCast** is a Flutter mobile application for fish market forecasting with weather integration. The app provides weather forecasts, moon phase tracking, fish price predictions, and location-based services, targeting fishermen and fish market stakeholders in the Philippines (particularly Zamboanga City).

## Commands

### Development
```bash
# Run the app in development mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload (enabled by default)
flutter run --hot

# Build for Android
flutter build apk

# Build for Android (release mode)
flutter build apk --release

# Generate app icons
flutter pub run flutter_launcher_icons
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code according to Dart style guide
dart format lib/

# Format specific file
dart format lib/main.dart
```

### Dependencies
```bash
# Install/update dependencies
flutter pub get

# Upgrade dependencies to latest versions
flutter pub upgrade

# Clean build cache
flutter clean

# Rebuild after clean
flutter pub get && flutter run
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase initialization
├── core/                        # Shared utilities, services, models
│   ├── models/                  # Data models
│   │   ├── weather_model.dart   # WeatherData, CurrentWeather
│   │   ├── fish_type_model.dart # FishType model
│   │   ├── location_model.dart  # LocationData model
│   │   └── user_model.dart      # UserModel for Firestore
│   ├── services/                # Business logic & API integration
│   │   ├── auth_service.dart    # Authentication wrapper (ChangeNotifier)
│   │   ├── firebase_service.dart # Firebase Auth/Firestore operations (singleton)
│   │   ├── weather_service.dart # Open-Meteo API integration (singleton)
│   │   ├── location_service.dart # Geolocator & geocoding (singleton)
│   │   ├── moon_phase_service.dart # Moon phase calculations
│   │   ├── fish_type_service.dart # Fish types with 24h caching
│   │   └── cache_service.dart   # SharedPreferences caching utility
│   ├── widgets/                 # Reusable widgets
│   │   ├── cards/              # WeatherCard, MoonPhasesCard
│   │   ├── bar/                # AppBar, NotificationBar
│   │   ├── graph/              # Dynamic chart widgets (fl_chart)
│   │   └── auth_wrapper.dart   # Authentication flow handler
│   └── utils/
│       └── constants.dart       # App color palette
├── features/                    # Feature modules (screens)
│   ├── authentication/          # Login, signup, password reset
│   ├── dashboard/               # Home screen with weather & fish data
│   ├── weather/                 # Detailed weather view
│   ├── forecast/                # Fish price forecasting
│   ├── notifications/           # Notifications management
│   ├── profile/                 # User profile & settings
│   │   └── legal/              # Privacy policy, terms of service
│   ├── settings/                # App settings
│   └── help/                    # Help & support
```

### Key Design Patterns

**Services (Singleton Pattern)**
- Most services use singleton pattern (`factory` constructor returns `_instance`)
- Access via: `ServiceName()` or `ServiceName.instance`
- Examples: `WeatherService()`, `LocationService()`, `FirebaseService.instance`

**State Management**
- `AuthService` extends `ChangeNotifier` for reactive authentication state
- Most widgets use `StatefulWidget` with local state management
- Firebase auth state is streamed via `authStateChanges`

**Authentication Flow**
1. `main.dart` initializes Firebase and launches `AuthWrapper`
2. `AuthWrapper` uses `StreamBuilder` on `authStateChanges`
3. Authenticated → `MainNavigation` (bottom nav with 5 pages)
4. Not authenticated → `LoginPage`

**Navigation**
- Bottom navigation with `IndexedStack` (preserves page state)
- Pages: Dashboard, Weather, Forecast, Notifications, Profile

### Critical Services

**FirebaseService**
- Singleton managing Firebase Auth & Firestore
- Methods: registration, login (email/password & Google), user CRUD operations
- Stores user data in `users` collection with fields: `email`, `first_name`, `last_name`, `profile_picture_url`, `created_at`, `updated_at`
- Google Sign-In: Always signs out first to clear cached credentials
- Re-authentication required for sensitive operations (account deletion, etc.)

**WeatherService**
- Uses Open-Meteo API (no API key required)
- Caching: Current weather (15 min), weekly forecast (1 hour)
- Methods: `getCurrentWeather()`, `getWeeklyForecast()`
- Both support `forceRefresh` parameter to bypass cache
- Returns WMO weather codes (0=clear, 1-3=cloudy, 61-67=rain, etc.)

**LocationService**
- Uses `geolocator` for GPS and `geocoding` for address lookup
- Fallback location: Zamboanga City (6.9214, 122.0790)
- `getLocationWithCache()` uses last known position if < 5 min old
- Always checks permissions before accessing location

**FishTypeService**
- Manages fish types with 24-hour cache
- Currently uses default data (ready for API integration)
- Default fish: Galunggong, Tilapia, Bangus, Tuna, Maya-maya, Lapu-lapu, etc.
- Methods: `getFishTypes()`, `getFishTypeNames()`, `getFishTypeById()`, `getFishTypeByName()`
- See `lib/core/services/FISH_TYPES_README.md` for API integration guide

**CacheService**
- Wrapper around `SharedPreferences`
- Stores JSON data with timestamps
- Methods: `saveCache()`, `getCache()`, `clearCache()`, `clearAllCache()`

### Dynamic Chart System

The app uses `fl_chart` with custom wrappers for consistent styling:

**LinechartWidget** - Single line chart
```dart
LinechartWidget(
  data: List<ChartDataPoint>,  // Required
  lineConfig: LineConfig(...),  // Optional: color, label, dots, area
  axisConfig: AxisConfig(...),  // Optional: labels, intervals, ranges
)
```

**DualLinechartWidget** - Dual line comparison
```dart
DualLinechartWidget(
  line1Data: List<ChartDataPoint>,
  line2Data: List<ChartDataPoint>,
  line1Config: LineConfig(...),
  line2Config: LineConfig(...),
  axisConfig: AxisConfig(...),
)
```

**Creating Chart Data**
```dart
// Helper function
List<ChartDataPoint> data = createChartData(
  yValues: [25, 30, 28, 35],
  labels: ['Jan', 'Feb', 'Mar', 'Apr'],  // Optional
);

// Or manually
List<ChartDataPoint> data = [
  ChartDataPoint(x: 0, y: 25, label: 'Jan'),
  ChartDataPoint(x: 1, y: 30, label: 'Feb'),
];
```

See `lib/core/widgets/graph/README.md` for detailed examples and customization options.

## Firebase Configuration

### Required Setup
1. Firebase project must be initialized before app runs (done in `main.dart`)
2. Android: `google-services.json` must be in `android/app/`
3. iOS: `GoogleService-Info.plist` must be in `ios/Runner/`
4. Firebase plugins used: `firebase_core`, `firebase_auth`, `cloud_firestore`

### Firestore Structure
```
users/
  {userId}/
    - email: string
    - first_name: string
    - last_name: string
    - profile_picture_url: string (optional)
    - created_at: timestamp
    - updated_at: timestamp
```

## Styling & Theming

### Color Palette (constants.dart)
- **kPrimaryColor**: `#03457F` (dark blue)
- **kSecondaryColor**: `#009BDD` (bright blue)
- **kAccentColor**: `#6FC5C8` (teal)
- **kForegroundColor**: `#05121D` (almost black)
- **kBackgroundColor**: `#FFFFFF` (white)
- **kSecondaryTextColor**: `#606060` (gray)

### Typography
- Primary font: **Urbanist** (weights 100-900, includes italic)
- Font files located in `assets/fonts/Urbanist/static/`

### Assets
```
assets/
├── logo.svg
├── app_icon.png
├── weather_card/         # Weather condition icons
├── moon_phases_card/     # Moon phase icons
├── login_button/         # Social login buttons
└── fonts/
```

## Development Guidelines

### Adding New Services
1. Use singleton pattern for stateless services
2. Implement caching where appropriate (use `CacheService`)
3. Handle errors gracefully with try-catch and return sensible defaults
4. Document public methods with dartdoc comments

### Working with Firebase
- Never expose sensitive operations without re-authentication
- Always check `currentUser != null` before Firebase operations
- Use `mounted` check before `setState()` in async callbacks
- Handle `FirebaseAuthException` separately from generic exceptions

### Location Handling
- Always handle permission denials gracefully
- Provide Zamboanga City as fallback when location fails
- Use `getLocationWithCache()` for better performance
- Timeout location requests (default: 10 seconds)

### Weather Integration
- Weather codes follow WMO standard (see `WeatherData.condition` getter)
- Temperature is in Celsius by default
- Cache weather data to minimize API calls (Open-Meteo free tier limits)
- Use `forceRefresh: true` only when user explicitly refreshes

### Code Style
- Follow Dart style guide (use `dart format`)
- Use `const` constructors wherever possible for performance
- Prefer `final` over `var` for immutable variables
- Use trailing commas for better formatting

### State Management
- Use `StatefulWidget` for simple local state
- Extract complex state logic to services
- Use `StreamBuilder` for Firebase real-time updates
- Call `notifyListeners()` in `AuthService` after state changes

### Testing Considerations
- Test with location services disabled
- Test with poor network connectivity
- Test authentication flows (email, Google, logout)
- Test with different screen sizes (responsive design)

## Common Development Tasks

### Adding a New Fish Type
1. Update default list in `FishTypeService._defaultFishTypes`
2. Or integrate with backend API (see `FISH_TYPES_README.md`)
3. Fish types are cached for 24 hours

### Integrating a New API Endpoint
1. Add dependencies if needed (e.g., `http` package)
2. Create a service in `lib/core/services/`
3. Implement caching using `CacheService`
4. Handle errors with fallback data
5. Use singleton pattern for stateless services

### Adding a New Feature Page
1. Create folder in `lib/features/<feature_name>/`
2. Create main page file: `<feature_name>.dart`
3. Add to `MainNavigation` in `main.dart` if needed
4. Add navigation item to bottom nav bar if applicable

### Customizing Chart Appearance
1. Modify default configs in `lib/core/widgets/graph/`
2. Or pass custom `LineConfig` and `AxisConfig` to widgets
3. Colors should use constants from `constants.dart`
4. See graph README for detailed customization options

## Troubleshooting

### "MissingPluginException" errors
```bash
flutter clean
flutter pub get
# Rebuild the app
```

### Location permission issues
- Check `AndroidManifest.xml` has location permissions
- For iOS, check `Info.plist` has location usage descriptions
- Test on physical device (simulators may not support location)

### Firebase authentication not working
- Verify `google-services.json` / `GoogleService-Info.plist` are present
- Check Firebase Console has correct SHA-1/SHA-256 (Android)
- Ensure authentication methods are enabled in Firebase Console

### Charts not displaying correctly
- Verify data list is not empty
- Check x-values are unique and sorted
- Ensure y-values are within reasonable range
- See `lib/core/widgets/graph/README.md` for troubleshooting

### Google Sign-In fails repeatedly
- Service signs out before sign-in to clear cache
- If still failing, check Firebase project configuration
- Verify Google Sign-In is enabled in Firebase Console
- Check app's SHA-1 fingerprint is registered (Android)

## Platform-Specific Notes

### Android
- Min SDK: Check `android/app/build.gradle`
- Adaptive icon configured with app's blue color (#009BDD)
- Google Sign-In requires SHA-1/SHA-256 registration
- Location permissions in `AndroidManifest.xml`

### iOS
- Not fully configured in current setup (Android-focused)
- Will need iOS-specific setup for Firebase, location services, etc.
- Icon configuration in `pubspec.yaml` includes iOS

## External Dependencies

### Key Packages
- **firebase_auth** (6.0.2): Authentication
- **cloud_firestore** (6.0.1): Database
- **google_sign_in** (6.2.1): Google OAuth
- **open_meteo** (3.0.0): Weather API (no key required)
- **geolocator** (13.0.2): GPS location
- **geocoding** (3.0.0): Reverse geocoding
- **fl_chart** (1.0.0): Charts and graphs
- **flutter_svg** (2.2.0): SVG rendering
- **google_fonts** (6.3.0): Additional fonts (if needed)
- **intl** (0.19.0): Internationalization
- **shared_preferences** (2.2.2): Local storage
- **image_picker** (1.0.7): Image selection
- **smooth_page_indicator** (1.1.0): Page indicators

### Dev Dependencies
- **flutter_lints** (5.0.0): Linting rules
- **flutter_launcher_icons** (0.14.2): Icon generation
