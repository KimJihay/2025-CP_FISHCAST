import 'package:fishcast/core/models/fish_type_model.dart';

/// Service for managing fish types
/// This service provides methods to fetch fish types from API or use default values
class FishTypeService {
  // Singleton pattern
  static final FishTypeService _instance = FishTypeService._internal();
  factory FishTypeService() => _instance;
  FishTypeService._internal();

  // Cache for fish types
  List<FishType>? _cachedFishTypes;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiration = Duration(hours: 24);

  /// Default fish types (fallback if API fails)
  static final List<FishType> _defaultFishTypes = [
    FishType(id: '1', name: 'Galunggong', scientificName: 'Decapterus macrosoma'),
    FishType(id: '2', name: 'Tilapia', scientificName: 'Oreochromis niloticus'),
    FishType(id: '3', name: 'Bangus', scientificName: 'Chanos chanos'),
    FishType(id: '4', name: 'Tuna', scientificName: 'Thunnus'),
    FishType(id: '5', name: 'Maya-maya', scientificName: 'Lutjanus campechanus'),
    FishType(id: '6', name: 'Lapu-lapu', scientificName: 'Epinephelus'),
    FishType(id: '7', name: 'Hasa-hasa', scientificName: 'Rastrelliger kanagurta'),
    FishType(id: '8', name: 'Tanigue', scientificName: 'Scomberomorus commerson'),
    FishType(id: '9', name: 'Dalagang-bukid', scientificName: 'Caesio cuning'),
    FishType(id: '10', name: 'Alumahan', scientificName: 'Scomber japonicus'),
  ];

  /// Get fish types with caching
  /// Returns cached data if available and not expired, otherwise fetches from API
  Future<List<FishType>> getFishTypes({bool forceRefresh = false}) async {
    // Check if cache is valid
    if (!forceRefresh && 
        _cachedFishTypes != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiration) {
      return _cachedFishTypes!;
    }

    try {
      // TODO: Replace with actual API call
      // Example:
      // final response = await http.get(Uri.parse('YOUR_API_URL/fish-types'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   _cachedFishTypes = data.map((json) => FishType.fromJson(json)).toList();
      //   _lastFetchTime = DateTime.now();
      //   return _cachedFishTypes!;
      // }
      
      // For now, simulate API delay and return default types
      await Future.delayed(const Duration(milliseconds: 500));
      
      _cachedFishTypes = _defaultFishTypes;
      _lastFetchTime = DateTime.now();
      return _cachedFishTypes!;
      
    } catch (e) {
      // If API fails, return default fish types
      print('Error fetching fish types: $e');
      return _defaultFishTypes;
    }
  }

  /// Get fish type names only (for dropdowns)
  Future<List<String>> getFishTypeNames({bool forceRefresh = false}) async {
    final fishTypes = await getFishTypes(forceRefresh: forceRefresh);
    return fishTypes.map((fish) => fish.name).toList();
  }

  /// Get fish type by ID
  Future<FishType?> getFishTypeById(String id) async {
    final fishTypes = await getFishTypes();
    try {
      return fishTypes.firstWhere((fish) => fish.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get fish type by name
  Future<FishType?> getFishTypeByName(String name) async {
    final fishTypes = await getFishTypes();
    try {
      return fishTypes.firstWhere((fish) => fish.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache (useful when you want to force refresh)
  void clearCache() {
    _cachedFishTypes = null;
    _lastFetchTime = null;
  }

  /// Get default fish types (without API call)
  List<FishType> getDefaultFishTypes() {
    return _defaultFishTypes;
  }

  /// Get default fish type names (without API call)
  List<String> getDefaultFishTypeNames() {
    return _defaultFishTypes.map((fish) => fish.name).toList();
  }
}
