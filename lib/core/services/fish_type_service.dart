import 'dart:developer' as developer;

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
  /// These match the fish types available in the backend API
  static final List<FishType> _defaultFishTypes = [
    FishType(id: '1', name: 'Alumahan (Striped Mackerel)', scientificName: 'Rastrelliger kanagurta'),
    FishType(id: '2', name: 'Bangus (Milk Fish)', scientificName: 'Chanos chanos'),
    FishType(id: '3', name: 'Bariles (Yellow Fin Tuna)', scientificName: 'Thunnus albacares'),
    FishType(id: '4', name: 'Culisi (Nemipterid)', scientificName: 'Nemipterus'),
    FishType(id: '5', name: 'Galunggong (Round Scad)', scientificName: 'Decapterus macrosoma'),
    FishType(id: '6', name: 'Gulyasan or Puyan (Skipjack Tuna)', scientificName: 'Katsuwonus pelamis'),
    FishType(id: '7', name: 'Lapu-lapu (Grouper)', scientificName: 'Epinephelus'),
    FishType(id: '8', name: 'Malasugi (Blue Marlin)', scientificName: 'Makaira nigricans'),
    FishType(id: '9', name: 'Matang Baka (Big-eyed Scads)', scientificName: 'Selar crumenophthalmus'),
    FishType(id: '10', name: 'Maya-maya (Snapper)', scientificName: 'Lutjanus campechanus'),
    FishType(id: '11', name: 'Mulmul (Parrot Fish)', scientificName: 'Scaridae'),
    FishType(id: '12', name: 'Samaral (Siganid)', scientificName: 'Siganus'),
    FishType(id: '13', name: 'Sting Ray', scientificName: 'Dasyatidae'),
    FishType(id: '14', name: 'Talakitok (Crevalle)', scientificName: 'Caranx'),
    FishType(id: '15', name: 'Tamban (Indian Sardines)', scientificName: 'Sardinella longiceps'),
    FishType(id: '16', name: 'Tanguigue (Spanish Mackerel)', scientificName: 'Scomberomorus commerson'),
    FishType(id: '17', name: 'Tulingan (Frigate Tuna)', scientificName: 'Auxis thazard'),
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
      developer.log('Error fetching fish types: $e', name: 'FishTypeService');
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
