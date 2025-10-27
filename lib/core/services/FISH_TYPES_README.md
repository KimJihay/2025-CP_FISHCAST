# Fish Type Service - Developer Guide

This guide explains how to use the dynamic fish type system in the Fishcast application.

## Overview

The `FishTypeService` provides a centralized way to manage fish types throughout the application. It supports:
- ✅ **API Integration** - Fetch fish types from your backend
- ✅ **Caching** - 24-hour cache to reduce API calls
- ✅ **Fallback** - Default fish types if API fails
- ✅ **Type Safety** - Structured `FishType` model
- ✅ **Easy Integration** - Simple async methods

---

## Quick Start

### Basic Usage

```dart
import 'package:fishcast/core/services/fish_type_service.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final FishTypeService _fishTypeService = FishTypeService();
  List<String> fishTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
  }

  Future<void> _loadFishTypes() async {
    final types = await _fishTypeService.getFishTypeNames();
    setState(() {
      fishTypes = types;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }

    return DropdownButton<String>(
      items: fishTypes.map((name) => DropdownMenuItem(
        value: name,
        child: Text(name),
      )).toList(),
      onChanged: (value) { /* handle change */ },
    );
  }
}
```

---

## FishType Model

### Structure

```dart
class FishType {
  final String id;              // Unique identifier
  final String name;            // Display name (e.g., "Galunggong")
  final String? scientificName; // Optional scientific name
  final String? category;       // Optional category
  final bool isActive;          // Whether fish type is active
}
```

### Creating FishType

```dart
// Manual creation
FishType fish = FishType(
  id: '1',
  name: 'Galunggong',
  scientificName: 'Decapterus macrosoma',
  category: 'Pelagic',
  isActive: true,
);

// From JSON (API response)
FishType fish = FishType.fromJson({
  'id': '1',
  'name': 'Galunggong',
  'scientific_name': 'Decapterus macrosoma',
  'category': 'Pelagic',
  'is_active': true,
});

// To JSON (for API requests)
Map<String, dynamic> json = fish.toJson();
```

---

## FishTypeService Methods

### 1. Get Fish Types (Full Objects)

```dart
Future<List<FishType>> getFishTypes({bool forceRefresh = false})
```

Returns full `FishType` objects with all details.

**Example:**
```dart
final fishTypes = await _fishTypeService.getFishTypes();
for (var fish in fishTypes) {
  print('${fish.name} - ${fish.scientificName}');
}
```

**Force Refresh:**
```dart
// Bypass cache and fetch fresh data
final fishTypes = await _fishTypeService.getFishTypes(forceRefresh: true);
```

### 2. Get Fish Type Names (Simple List)

```dart
Future<List<String>> getFishTypeNames({bool forceRefresh = false})
```

Returns just the names as strings (perfect for dropdowns).

**Example:**
```dart
final names = await _fishTypeService.getFishTypeNames();
// Returns: ['Galunggong', 'Tilapia', 'Bangus', ...]
```

### 3. Get Fish Type by ID

```dart
Future<FishType?> getFishTypeById(String id)
```

Find a specific fish type by its ID.

**Example:**
```dart
final fish = await _fishTypeService.getFishTypeById('1');
if (fish != null) {
  print('Found: ${fish.name}');
}
```

### 4. Get Fish Type by Name

```dart
Future<FishType?> getFishTypeByName(String name)
```

Find a specific fish type by its name.

**Example:**
```dart
final fish = await _fishTypeService.getFishTypeByName('Galunggong');
if (fish != null) {
  print('ID: ${fish.id}, Scientific: ${fish.scientificName}');
}
```

### 5. Clear Cache

```dart
void clearCache()
```

Force clear the cache (next call will fetch fresh data).

**Example:**
```dart
_fishTypeService.clearCache();
final freshData = await _fishTypeService.getFishTypes();
```

### 6. Get Default Fish Types (No API Call)

```dart
List<FishType> getDefaultFishTypes()
List<String> getDefaultFishTypeNames()
```

Get default fish types without making an API call.

**Example:**
```dart
// Synchronous - no await needed
final defaults = _fishTypeService.getDefaultFishTypeNames();
```

---

## Caching Behavior

The service automatically caches fish types for **24 hours** to reduce API calls.

### Cache Flow:
1. First call → Fetches from API → Stores in cache
2. Subsequent calls (within 24h) → Returns cached data
3. After 24h → Automatically fetches fresh data
4. API failure → Returns default fish types

### Manual Cache Control:

```dart
// Clear cache to force refresh
_fishTypeService.clearCache();

// Or use forceRefresh parameter
final fresh = await _fishTypeService.getFishTypes(forceRefresh: true);
```

---

## API Integration

### Current Implementation

The service is ready for API integration. Currently uses default data with simulated delay.

### How to Connect Your API

**Step 1:** Open `lib/core/services/fish_type_service.dart`

**Step 2:** Find the `getFishTypes()` method

**Step 3:** Replace the TODO section with your API call:

```dart
Future<List<FishType>> getFishTypes({bool forceRefresh = false}) async {
  // ... cache check code ...

  try {
    // Replace this section:
    final response = await http.get(
      Uri.parse('https://your-api.com/api/fish-types'),
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _cachedFishTypes = data.map((json) => FishType.fromJson(json)).toList();
      _lastFetchTime = DateTime.now();
      return _cachedFishTypes!;
    } else {
      throw Exception('Failed to load fish types');
    }
  } catch (e) {
    print('Error fetching fish types: $e');
    return _defaultFishTypes;
  }
}
```

**Step 4:** Add http package to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

**Step 5:** Import http in the service:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
```

### Expected API Response Format

```json
[
  {
    "id": "1",
    "name": "Galunggong",
    "scientific_name": "Decapterus macrosoma",
    "category": "Pelagic",
    "is_active": true
  },
  {
    "id": "2",
    "name": "Tilapia",
    "scientific_name": "Oreochromis niloticus",
    "category": "Freshwater",
    "is_active": true
  }
]
```

---

## Error Handling

The service includes built-in error handling:

```dart
try {
  final fishTypes = await _fishTypeService.getFishTypes();
  // Use fishTypes
} catch (e) {
  // Service automatically returns default fish types on error
  // You can add additional error handling here if needed
  print('Error: $e');
}
```

**Automatic Fallback:**
- If API fails → Returns default fish types
- If network error → Returns default fish types
- If parsing error → Returns default fish types

---

## Examples

### Example 1: Dropdown with Fish Types

```dart
class FishDropdown extends StatefulWidget {
  @override
  _FishDropdownState createState() => _FishDropdownState();
}

class _FishDropdownState extends State<FishDropdown> {
  final FishTypeService _service = FishTypeService();
  List<String> fishTypes = [];
  String? selectedFish;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
  }

  Future<void> _loadFishTypes() async {
    final types = await _service.getFishTypeNames();
    setState(() {
      fishTypes = types;
      selectedFish = types.isNotEmpty ? types.first : null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }

    return DropdownButton<String>(
      value: selectedFish,
      items: fishTypes.map((name) => DropdownMenuItem(
        value: name,
        child: Text(name),
      )).toList(),
      onChanged: (value) {
        setState(() => selectedFish = value);
      },
    );
  }
}
```

### Example 2: Fish List with Details

```dart
class FishListPage extends StatefulWidget {
  @override
  _FishListPageState createState() => _FishListPageState();
}

class _FishListPageState extends State<FishListPage> {
  final FishTypeService _service = FishTypeService();
  List<FishType> fishTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
  }

  Future<void> _loadFishTypes() async {
    final types = await _service.getFishTypes();
    setState(() {
      fishTypes = types;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: fishTypes.length,
      itemBuilder: (context, index) {
        final fish = fishTypes[index];
        return ListTile(
          title: Text(fish.name),
          subtitle: Text(fish.scientificName ?? 'No scientific name'),
          trailing: fish.isActive 
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.close, color: Colors.red),
        );
      },
    );
  }
}
```

### Example 3: Search Fish Types

```dart
class FishSearchPage extends StatefulWidget {
  @override
  _FishSearchPageState createState() => _FishSearchPageState();
}

class _FishSearchPageState extends State<FishSearchPage> {
  final FishTypeService _service = FishTypeService();
  List<FishType> allFish = [];
  List<FishType> filteredFish = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
    searchController.addListener(_filterFish);
  }

  Future<void> _loadFishTypes() async {
    final types = await _service.getFishTypes();
    setState(() {
      allFish = types;
      filteredFish = types;
    });
  }

  void _filterFish() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredFish = allFish.where((fish) =>
        fish.name.toLowerCase().contains(query) ||
        (fish.scientificName?.toLowerCase().contains(query) ?? false)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Search fish',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredFish.length,
            itemBuilder: (context, index) {
              final fish = filteredFish[index];
              return ListTile(
                title: Text(fish.name),
                subtitle: Text(fish.scientificName ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Example 4: Refresh Fish Types

```dart
class RefreshableFishList extends StatefulWidget {
  @override
  _RefreshableFishListState createState() => _RefreshableFishListState();
}

class _RefreshableFishListState extends State<RefreshableFishList> {
  final FishTypeService _service = FishTypeService();
  List<String> fishTypes = [];

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
  }

  Future<void> _loadFishTypes() async {
    final types = await _service.getFishTypeNames();
    setState(() => fishTypes = types);
  }

  Future<void> _refreshFishTypes() async {
    // Force refresh from API
    final types = await _service.getFishTypeNames(forceRefresh: true);
    setState(() => fishTypes = types);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshFishTypes,
      child: ListView.builder(
        itemCount: fishTypes.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(fishTypes[index]));
        },
      ),
    );
  }
}
```

---

## Default Fish Types

The service includes these default fish types:

1. **Galunggong** - *Decapterus macrosoma*
2. **Tilapia** - *Oreochromis niloticus*
3. **Bangus** - *Chanos chanos*
4. **Tuna** - *Thunnus*
5. **Maya-maya** - *Lutjanus campechanus*
6. **Lapu-lapu** - *Epinephelus*
7. **Hasa-hasa** - *Rastrelliger kanagurta*
8. **Tanigue** - *Scomberomorus commerson*
9. **Dalagang-bukid** - *Caesio cuning*
10. **Alumahan** - *Scomber japonicus*

---

## Best Practices

1. **Initialize Early**: Load fish types in `initState()` to avoid delays
2. **Handle Loading States**: Show loading indicators while fetching
3. **Error Handling**: Service handles errors automatically, but you can add custom handling
4. **Cache Management**: Use default cache (24h) unless you need real-time updates
5. **Validation**: Always check if dropdown value exists in the list before setting it

---

## Troubleshooting

**Problem**: Fish types not loading
- **Solution**: Check network connection, verify API endpoint

**Problem**: Dropdown shows empty
- **Solution**: Ensure `_loadFishTypes()` is called in `initState()`

**Problem**: Old data showing
- **Solution**: Call `clearCache()` or use `forceRefresh: true`

**Problem**: API returns different format
- **Solution**: Update `FishType.fromJson()` to match your API response

---

## Support

For questions or issues, refer to the main project documentation or contact the development team.
