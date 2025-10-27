import 'dart:convert';
import 'package:fishcast/core/models/fish_forecast_model.dart';
import 'package:fishcast/core/services/cache_service.dart';
import 'package:http/http.dart' as http;

/// Service for fetching fish price forecasts from the backend API
class FishForecastService {
  // Singleton pattern
  static final FishForecastService _instance = FishForecastService._internal();
  factory FishForecastService() => _instance;
  FishForecastService._internal();

  // Backend API base URL
  static const String _baseUrl = 'https://fishcast-backend-coq5.onrender.com';
  
  // Cache service
  final CacheService _cacheService = CacheService();
  
  // Cache keys
  static const String _allForecastsCacheKey = 'all_forecasts';
  static const String _forecastCachePrefix = 'forecast_';
  
  // Cache expiration (30 minutes for forecasts)
  static const Duration _cacheExpiration = Duration(minutes: 30);

  /// Get forecast for a specific fish type
  /// 
  /// [fishType] - The fish type identifier (e.g., 'galunggong_round_scad')
  /// [forceRefresh] - If true, bypasses cache and fetches fresh data
  /// 
  /// Returns FishForecast object or null if error occurs
  Future<FishForecast?> getForecast(String fishType, {bool forceRefresh = false}) async {
    final cacheKey = '$_forecastCachePrefix$fishType';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          return FishForecast.fromJson(cachedData);
        } catch (e) {
          print('Error parsing cached forecast: $e');
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/forecast/$fishType');
      print('Fetching forecast from: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - backend might be starting up (cold start)');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final forecast = FishForecast.fromJson(data);
        
        // Cache the response
        await _cacheService.saveCache(cacheKey, data, _cacheExpiration);
        
        return forecast;
      } else if (response.statusCode == 404) {
        print('Fish type not found: $fishType');
        return null;
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching forecast for $fishType: $e');
      
      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          print('Using expired cache data due to network error');
          return FishForecast.fromJson(cachedData);
        } catch (cacheError) {
          print('Failed to parse cached data: $cacheError');
        }
      }
      
      return null;
    }
  }

  /// Get forecasts for all fish types
  /// 
  /// [forceRefresh] - If true, bypasses cache and fetches fresh data
  /// 
  /// Returns a map of fish type identifiers to FishForecast objects
  Future<Map<String, FishForecast>?> getAllForecasts({bool forceRefresh = false}) async {
    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(_allForecastsCacheKey);
      if (cachedData != null) {
        try {
          return _parseAllForecastsResponse(cachedData);
        } catch (e) {
          print('Error parsing cached all forecasts: $e');
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/forecast');
      print('Fetching all forecasts from: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - backend might be starting up (cold start)');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Cache the response
        await _cacheService.saveCache(_allForecastsCacheKey, data, _cacheExpiration);
        
        return _parseAllForecastsResponse(data);
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching all forecasts: $e');
      
      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(_allForecastsCacheKey);
      if (cachedData != null) {
        try {
          print('Using expired cache data due to network error');
          return _parseAllForecastsResponse(cachedData);
        } catch (cacheError) {
          print('Failed to parse cached data: $cacheError');
        }
      }
      
      return null;
    }
  }

  /// Parse the all forecasts API response
  Map<String, FishForecast> _parseAllForecastsResponse(Map<String, dynamic> data) {
    final forecastsData = data['forecasts'] as Map<String, dynamic>;
    final Map<String, FishForecast> result = {};

    forecastsData.forEach((fishType, forecastList) {
      try {
        final forecast = FishForecast(
          fishType: fishType,
          forecast: (forecastList as List<dynamic>)
              .map((item) => ForecastDataPoint.fromJson(item as Map<String, dynamic>))
              .toList(),
          updatedAt: data['updated_at'] != null 
              ? DateTime.tryParse(data['updated_at']) 
              : null,
        );
        result[fishType] = forecast;
      } catch (e) {
        print('Error parsing forecast for $fishType: $e');
      }
    });

    return result;
  }

  /// Check if the backend API is healthy
  Future<bool> isApiHealthy() async {
    try {
      final url = Uri.parse('$_baseUrl/');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'online';
      }
      return false;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  /// Get available fish types from the backend
  Future<List<String>?> getAvailableFishTypes() async {
    try {
      final url = Uri.parse('$_baseUrl/');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fishList = data['available_fish'] as List<dynamic>;
        return fishList.map((fish) => fish.toString()).toList();
      }
      return null;
    } catch (e) {
      print('Error fetching available fish types: $e');
      return null;
    }
  }

  /// Clear all forecast caches
  Future<void> clearCache() async {
    await _cacheService.clearCache(_allForecastsCacheKey);
    // Note: Individual forecast caches will expire naturally
    // or you can implement a method to clear all with prefix
  }

  /// Convert fish display name to API identifier
  /// Example: "Galunggong (Round Scad)" -> "galunggong_round_scad"
  String fishNameToApiId(String displayName) {
    return displayName
        .toLowerCase()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '_')
        .replaceAll('-', '_');
  }

  /// Convert API identifier to display name
  /// Example: "galunggong_round_scad" -> "Galunggong Round Scad"
  String apiIdToDisplayName(String apiId) {
    return apiId
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
