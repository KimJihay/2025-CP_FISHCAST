import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Cache duration constants (in minutes)
  static const int weatherCacheDuration = 30; // 30 minutes
  static const int forecastCacheDuration = 60; // 1 hour
  static const int locationCacheDuration = 60; // 1 hour
  static const int moonPhaseCacheDuration = 1440; // 24 hours

  /// Save data to cache with timestamp
  Future<void> saveCache(String key, Map<String, dynamic> data) async {
    await init();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _prefs?.setString(key, jsonEncode(cacheData));
  }

  /// Get cached data if not expired
  Future<Map<String, dynamic>?> getCache(String key, int maxAgeMinutes) async {
    await init();
    final cachedString = _prefs?.getString(key);

    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final ageMinutes = (now - timestamp) / 1000 / 60;

      if (ageMinutes < maxAgeMinutes) {
        return cacheData['data'] as Map<String, dynamic>;
      } else {
        // Cache expired, remove it
        await clearCache(key);
        return null;
      }
    } catch (e) {
      // Invalid cache data, remove it
      await clearCache(key);
      return null;
    }
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    await init();
    await _prefs?.remove(key);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await init();
    await _prefs?.clear();
  }

  /// Check if cache exists and is valid
  Future<bool> isCacheValid(String key, int maxAgeMinutes) async {
    final cache = await getCache(key, maxAgeMinutes);
    return cache != null;
  }

  // Cache keys
  static const String currentWeatherKey = 'current_weather';
  static const String weeklyForecastKey = 'weekly_forecast';
  static const String currentLocationKey = 'current_location';
  static const String moonPhaseKey = 'moon_phase';
  static const String moonCalendarKey = 'moon_calendar';
}
