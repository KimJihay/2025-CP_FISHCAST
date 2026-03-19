import 'dart:convert';
import 'dart:developer' as developer;
import 'package:fishcast/core/models/fish_forecast_model.dart';
import 'package:fishcast/core/services/cache_service.dart';
import 'package:fishcast/core/utils/constants.dart';
import 'package:http/http.dart' as http;

void _log(String message) {
  developer.log(message, name: 'FishForecastService');
}

/// Service for fetching fish price forecasts from the backend API
class FishForecastService {
  // Singleton pattern
  static final FishForecastService _instance = FishForecastService._internal();
  factory FishForecastService() => _instance;
  FishForecastService._internal();

  // Backend API base URL
  static const String _baseUrl = kBaseUrl;

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
  Future<FishForecast?> getForecast(
    String fishType, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$_forecastCachePrefix$fishType';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          return FishForecast.fromJson(cachedData);
        } catch (e) {
          _log('Error parsing cached forecast: $e');
          // Continue to fetch from API if cache parsing fails
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/forecast/$fishType');
      _log('Fetching forecast from: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - backend might be starting up (cold start)',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final forecast = FishForecast.fromJson(data);

        // Cache the response
        await _cacheService.saveCache(cacheKey, data, _cacheExpiration);

        return forecast;
      } else if (response.statusCode == 404) {
        _log('Fish type not found: $fishType');
        return null;
      } else {
        _log('API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _log('Error fetching forecast for $fishType: $e');

      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          _log('Using expired cache data due to network error');
          return FishForecast.fromJson(cachedData);
        } catch (cacheError) {
          _log('Failed to parse cached data: $cacheError');
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
  Future<Map<String, FishForecast>?> getAllForecasts({
    bool forceRefresh = false,
  }) async {
    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(_allForecastsCacheKey);
      if (cachedData != null) {
        try {
          return _parseAllForecastsResponse(cachedData);
        } catch (e) {
          _log('Error parsing cached all forecasts: $e');
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/forecast');
      _log('Fetching all forecasts from: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - backend might be starting up (cold start)',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cache the response
        await _cacheService.saveCache(
          _allForecastsCacheKey,
          data,
          _cacheExpiration,
        );

        return _parseAllForecastsResponse(data);
      } else {
        _log('API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _log('Error fetching all forecasts: $e');

      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(_allForecastsCacheKey);
      if (cachedData != null) {
        try {
          _log('Using expired cache data due to network error');
          return _parseAllForecastsResponse(cachedData);
        } catch (cacheError) {
          _log('Failed to parse cached data: $cacheError');
        }
      }

      return null;
    }
  }

  /// Parse the all forecasts API response
  Map<String, FishForecast> _parseAllForecastsResponse(
    Map<String, dynamic> data,
  ) {
    final forecastsData = data['forecasts'] as Map<String, dynamic>;
    final Map<String, FishForecast> result = {};

    forecastsData.forEach((fishType, forecastList) {
      try {
        final forecast = FishForecast(
          fishType: fishType,
          forecast: (forecastList as List<dynamic>)
              .map(
                (item) =>
                    ForecastDataPoint.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
          updatedAt: data['updated_at'] != null
              ? DateTime.tryParse(data['updated_at'])
              : null,
        );
        result[fishType] = forecast;
      } catch (e) {
        _log('Error parsing forecast for $fishType: $e');
      }
    });

    return result;
  }

  /// Filter forecasts by price range over the next 7 days (forecast data only)
  ///
  /// [filterDate] - If provided, only returns matches for that specific date
  Future<List<PriceMatch>?> getForecastMatchesByPriceRange({
    double? minPrice,
    double? maxPrice,
    DateTime? filterDate,
  }) async {
    try {
      final all = await getAllForecasts(forceRefresh: true);
      if (all == null || all.isEmpty) return null;

      final matches = <PriceMatch>[];

      all.forEach((apiId, forecast) {
        for (final point in forecast.forecast) {
          // If a specific date filter is set, skip non-matching dates
          if (filterDate != null) {
            if (point.date.year != filterDate.year ||
                point.date.month != filterDate.month ||
                point.date.day != filterDate.day) {
              continue;
            }
          }

          final price = point.price;
          if (minPrice != null && price < minPrice) continue;
          if (maxPrice != null && price > maxPrice) continue;

          matches.add(
            PriceMatch(
              fishKey: apiId,
              fishName: apiIdToDisplayName(apiId),
              price: price,
              supplyKg: 0,
              date: point.date,
            ),
          );
          break; // keep first match per fish
        }
      });

      matches.sort((a, b) => a.price.compareTo(b.price));
      return matches;
    } catch (e) {
      _log('Error filtering forecast matches by price range: $e');
      return null;
    }
  }

  /// Fetch historical prices from the dataset for a specific date
  ///
  /// Calls the backend /prices/by-date endpoint to get actual recorded prices
  Future<List<PriceMatch>?> getPricesByDate({
    required DateTime date,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final queryParams = <String, String>{'date': dateStr};
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final url = Uri.parse('$_baseUrl/prices/by-date').replace(queryParameters: queryParams);
      _log('Fetching prices by date from: $url');

      final response = await http.get(url).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final matchesRaw = data['matches'] as List<dynamic>? ?? [];

        final matches = matchesRaw.map((m) {
          final map = m as Map<String, dynamic>;
          DateTime? parsedDate;
          if (data['date'] != null) {
            parsedDate = DateTime.tryParse(data['date'] as String);
          }
          return PriceMatch(
            fishKey: map['fish_key'] as String,
            fishName: map['fish_name'] as String,
            price: (map['price'] as num).toDouble(),
            supplyKg: (map['supply_kg'] as num?)?.toDouble() ?? 0,
            date: parsedDate,
          );
        }).toList();

        matches.sort((a, b) => a.price.compareTo(b.price));
        return matches;
      } else if (response.statusCode == 404) {
        _log('No records for date: $dateStr');
        return [];
      } else {
        _log('API error for prices by date: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error fetching prices by date: $e');
      return null;
    }
  }

  /// Check if the backend API is healthy
  Future<bool> isApiHealthy() async {
    try {
      final url = Uri.parse('$_baseUrl/');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'online';
      }
      return false;
    } catch (e) {
      _log('Health check failed: $e');
      return false;
    }
  }

  /// Get available fish types from the backend
  Future<List<String>?> getAvailableFishTypes() async {
    try {
      final url = Uri.parse('$_baseUrl/');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fishList = data['available_fish'] as List<dynamic>;
        return fishList.map((fish) => fish.toString()).toList();
      }
      return null;
    } catch (e) {
      _log('Error fetching available fish types: $e');
      return null;
    }
  }

  /// Get supply volume forecast for a specific fish type
  Future<Map<String, dynamic>?> getSupplyForecast(
    String fishType, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'supply_$fishType';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          return cachedData;
        } catch (e) {
          _log('Cache parse error for supply $fishType: $e');
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/supply/$fishType');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - backend might be starting up (cold start)',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cache the response
        await _cacheService.saveCache(cacheKey, data, _cacheExpiration);

        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      _log('Error fetching supply forecast for $fishType: $e');
      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          _log('Using expired cache data for supply $fishType');
          return cachedData;
        } catch (cacheError) {
          _log('Failed to parse cached supply data: $cacheError');
        }
      }

      return null;
    }
  }

  /// Clear all forecast caches
  Future<void> clearCache() async {
    await _cacheService.clearCache(_allForecastsCacheKey);
    // Note: Individual forecast caches will expire naturally
    // or you can implement a method to clear all with prefix
  }

  /// Get current (actual) prices from the dataset for all fish types
  Future<Map<String, dynamic>?> getCurrentPrices({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'current_prices';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          return cachedData;
        } catch (e) {
          _log('Cache parse error for current prices: $e');
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/prices/current');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - backend might be starting up (cold start)',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cache the response
        await _cacheService.saveCache(cacheKey, data, _cacheExpiration);

        return data;
      } else {
        _log('API error for current prices: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error fetching current prices: $e');
      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          _log('Using expired cache data for current prices');
          return cachedData;
        } catch (cacheError) {
          _log('Failed to parse cached current prices: $cacheError');
        }
      }

      return null;
    }
  }

  /// Get quarterly (90-day) supply volume forecast for a specific fish type
  Future<Map<String, dynamic>?> getQuarterlySupplyForecast(
    String fishType, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'supply_quarterly_$fishType';

    // Try to get from cache first
    if (!forceRefresh) {
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          return cachedData;
        } catch (e) {
          _log('Cache parse error for quarterly supply $fishType: $e');
        }
      }
    }

    try {
      final url = Uri.parse('$_baseUrl/supply/quarterly/$fishType');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - backend might be starting up (cold start)',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cache the response
        await _cacheService.saveCache(cacheKey, data, _cacheExpiration);

        return data;
      } else if (response.statusCode == 404) {
        _log('Quarterly supply not found for $fishType');
        return null;
      } else {
        _log('API error for quarterly supply $fishType: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log('Error fetching quarterly supply for $fishType: $e');
      // Try to return cached data even if expired
      final cachedData = await _cacheService.getCache(cacheKey);
      if (cachedData != null) {
        try {
          _log('Using expired cache data for quarterly supply $fishType');
          return cachedData;
        } catch (cacheError) {
          _log('Failed to parse cached quarterly supply: $cacheError');
        }
      }

      return null;
    }
  }

  /// Convert fish display name to API identifier
  /// Example: "Galunggong (Round Scad)" -> "galunggong_round_scad"
  String fishNameToApiId(String displayName) {
    return displayName
        .toLowerCase()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '_');
  }

  /// Convert API identifier to display name
  /// Example: "galunggong_round_scad" -> "Galunggong Round Scad"
  String apiIdToDisplayName(String apiId) {
    return apiId
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}

class PriceMatch {
  final String fishKey;
  final String fishName;
  final double price;
  final double supplyKg;
  final DateTime? date;

  PriceMatch({
    required this.fishKey,
    required this.fishName,
    required this.price,
    required this.supplyKg,
    this.date,
  });

  factory PriceMatch.fromJson(Map<String, dynamic> json) {
    return PriceMatch(
      fishKey: json['fish_key'] as String,
      fishName: json['fish_name'] as String,
      price: (json['price'] as num).toDouble(),
      supplyKg: (json['supply_kg'] as num).toDouble(),
    );
  }
}
