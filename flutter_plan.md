# Flutter App Implementation Plan - FishCast

## Overview

Implementation plan for the Flutter mobile app (`2025-CP_FISHCAST`) enhancements as per the capstone project requirements.

---

## Task 1: User Registration Enhancement

### Goal
Add a **Middle Name** field to the sign-up form.

### Files to Modify

#### [MODIFY] [signup_page.dart](file:///home/miguel/Documents/GitHub/2025-CP_FISHCAST/lib/features/authentication/signup_page.dart)

Add middle name input field between First Name and Last Name:

```dart
// Add controller (line ~20)
final _middleNameController = TextEditingController();

// Add to dispose() (line ~29)
_middleNameController.dispose();

// Add TextFormField after First Name (line ~215)
TextFormField(
  controller: _middleNameController,
  decoration: InputDecoration(
    hintText: "Middle Name (Optional)",
    border: OutlineInputBorder(),
  ),
),

// Update _handleEmailSignup to pass middle name (line ~77)
await _authService.registerWithEmailAndPassword(
  email: _emailController.text,
  password: _passwordController.text,
  firstName: _firstNameController.text,
  middleName: _middleNameController.text,  // NEW
  lastName: _lastNameController.text,
);
```

---

#### [MODIFY] [auth_service.dart](file:///home/miguel/Documents/GitHub/2025-CP_FISHCAST/lib/core/services/auth_service.dart)

Add `middleName` parameter to registration method:

```dart
Future<void> registerWithEmailAndPassword({
  required String email,
  required String password,
  required String firstName,
  String? middleName,  // NEW - optional
  required String lastName,
}) async {
  await _firebaseService.registerWithEmailAndPassword(
    email: email,
    password: password,
    firstName: firstName,
    middleName: middleName,  // NEW
    lastName: lastName,
  );
}
```

---

#### [MODIFY] [firebase_service.dart](file:///home/miguel/Documents/GitHub/2025-CP_FISHCAST/lib/core/services/firebase_service.dart)

Update `registerWithEmailAndPassword` and `_storeUserData`:

```dart
Future<User?> registerWithEmailAndPassword({
  required String email,
  required String password,
  required String firstName,
  String? middleName,  // NEW
  required String lastName,
}) async {
  // ... existing code ...
  await _storeUserData(
    userId: user.uid,
    email: email,
    firstName: firstName,
    middleName: middleName,  // NEW
    lastName: lastName,
  );
}

Future<void> _storeUserData({
  required String userId,
  required String email,
  required String firstName,
  String? middleName,  // NEW
  required String lastName,
  String? profilePictureUrl,
}) async {
  Map<String, dynamic> userData = {
    'email': email,
    'first_name': firstName,
    'middle_name': middleName,  // NEW
    'last_name': lastName,
    'isAdmin': false,  // Default to non-admin
    'created_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  };
  // ...
}
```

---

#### [MODIFY] [user_model.dart](file:///home/miguel/Documents/GitHub/2025-CP_FISHCAST/lib/core/models/user_model.dart)

Add `middleName` field:

```dart
class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String? middleName;  // NEW
  final String lastName;
  // ...

  // Update fullName getter
  String get fullName => middleName != null && middleName!.isNotEmpty
      ? '$firstName $middleName $lastName'
      : '$firstName $lastName';

  // Update fromFirestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      // ...
      middleName: data['middle_name'],  // NEW
      // ...
    );
  }
}
```

---

## Task 2: Forecasting Output Improvements

### Goal
Display forecasted price **separately** from historical/current prices for clearer interpretation.

### Files to Modify

#### [MODIFY] [forecast.dart](file:///home/miguel/Documents/GitHub/2025-CP_FISHCAST/lib/features/forecast/forecast.dart)

Update the forecast display to clearly distinguish:
- **Current Prices**: Labeled with "Current" or "Today"
- **Forecasted Prices**: Labeled with "Forecast" badge, different color styling

```dart
// In _buildForecastChart or build method:
// Add visual indicators
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: isForecast ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    isForecast ? 'FORECAST' : 'CURRENT',
    style: TextStyle(
      color: isForecast ? Colors.blue : Colors.green,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

---

## Task 3: Forecasted Price Page

### Goal
Create a **dedicated page** for forecasted prices with:
- Forecasted price values
- Relevant date ranges
- Supporting visualizations (charts/graphs)

### Files to Create

#### [NEW] [forecasted_prices_page.dart](file:///home/miguel/Documents/GitHub/2025-CP_FISHCAST/lib/features/forecast/forecasted_prices_page.dart)

New dedicated page with:

```dart
class ForecastedPricesPage extends StatefulWidget {
  @override
  State<ForecastedPricesPage> createState() => _ForecastedPricesPageState();
}

class _ForecastedPricesPageState extends State<ForecastedPricesPage> {
  // Features:
  // 1. Fish type selector dropdown
  // 2. Date range display (e.g., "Dec 24 - Dec 30, 2024")
  // 3. Table of forecasted prices per day
  // 4. Line chart showing 7-day forecast trend
  // 5. Price change indicators (↑ +2.5%, ↓ -1.2%)
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Forecasted Prices'),
      body: Column(
        children: [
          // Date Range Header
          _buildDateRangeHeader(),
          
          // Fish Type Selector
          _buildFishTypeSelector(),
          
          // Forecast Chart
          Expanded(
            flex: 2,
            child: _buildForecastChart(),
          ),
          
          // Forecast Table
          Expanded(
            flex: 3,
            child: _buildForecastTable(),
          ),
        ],
      ),
    );
  }
}
```

---

#### [MODIFY] Navigation

Add navigation to the new Forecasted Prices page from:
- Dashboard bottom navigation
- Forecast page quick action

---

## Firestore User Document (Updated)

```json
{
  "email": "user@example.com",
  "first_name": "Juan",
  "middle_name": "Dela",
  "last_name": "Cruz",
  "isAdmin": false,
  "profile_picture_url": null,
  "created_at": "2024-12-23T00:00:00Z",
  "updated_at": "2024-12-23T00:00:00Z"
}
```

---

## Verification Plan

### Manual Testing
1. **Middle Name**: Create new account → verify middle_name appears in Firestore
2. **Forecast Display**: Check forecast page shows clear labels for current vs forecast
3. **Forecast Page**: Navigate to new page → verify charts and data display correctly

### Device Testing
- Test on Android emulator
- Test on physical Android device (if available)
