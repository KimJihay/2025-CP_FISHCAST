import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:fishcast/core/models/seasonal_analysis_model.dart';
import 'package:fishcast/core/services/cache_service.dart';
import 'package:fishcast/core/utils/constants.dart';

void _logSeasonal(String message) {
  developer.log(message, name: 'SeasonalAnalysisService');
}

class SeasonalAnalysisService {
  // Singleton pattern
  static final SeasonalAnalysisService _instance =
      SeasonalAnalysisService._internal();
  factory SeasonalAnalysisService() => _instance;
  SeasonalAnalysisService._internal();

  // Backend API URL
  static const String _baseUrl = kBaseUrl;

  final CacheService _cacheService = CacheService();
  static const Duration _cacheValidity = Duration(
    hours: 24,
  ); // Cache for 24 hours

  /// Get overall seasonal analysis for all fish
  Future<SeasonalAnalysis?> getSeasonalAnalysis({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'seasonal_analysis_all';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey, _cacheValidity);
      if (cachedData != null) {
        try {
          return SeasonalAnalysis.fromJson(cachedData);
        } catch (e) {
          _logSeasonal('Error parsing cached seasonal analysis: $e');
        }
      }
    }

    // Fetch from API
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/seasonal'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache the response
        await _cacheService.saveCache(cacheKey, jsonData, _cacheValidity);

        return SeasonalAnalysis.fromJson(jsonData);
      } else {
        _logSeasonal('Failed to load seasonal analysis: ${response.statusCode}');
        _logSeasonal('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      _logSeasonal('Error fetching seasonal analysis: $e');
      return null;
    }
  }

  /// Get seasonal analysis for a specific fish type
  Future<FishSeasonalData?> getFishSeasonalAnalysis(
    String fishType, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'seasonal_analysis_$fishType';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey, _cacheValidity);
      if (cachedData != null) {
        try {
          return FishSeasonalData.fromJson(cachedData);
        } catch (e) {
          _logSeasonal('Error parsing cached fish seasonal analysis: $e');
        }
      }
    }

    // Fetch from API
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/seasonal/$fishType'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        // Cache the response
        await _cacheService.saveCache(cacheKey, jsonData, _cacheValidity);

        return FishSeasonalData.fromJson(jsonData);
      } else {
        _logSeasonal('Failed to load fish seasonal analysis: ${response.statusCode}');
        _logSeasonal('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      _logSeasonal('Error fetching fish seasonal analysis: $e');
      return null;
    }
  }

  /// Convert display name to API identifier
  /// Example: "Galunggong (Round Scad)" -> "galunggong_round_scad"
  String displayNameToApiId(String displayName) {
    return displayName
        .toLowerCase()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  /// Convert API identifier to display name
  /// Example: "galunggong_round_scad" -> "Galunggong (Round Scad)"
  String apiIdToDisplayName(String apiId) {
    // This is a simplified version - you might want to use FishTypeService for accurate mapping
    final words = apiId.split('_');
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Clear cached seasonal data
  Future<void> clearCache() async {
    await _cacheService.clearCache('seasonal_analysis_all');
    // Note: Individual fish caches will be cleared based on their own keys
  }
}
