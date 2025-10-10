import 'package:open_meteo/open_meteo.dart';
import '../models/weather_model.dart';
import 'cache_service.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final _weatherApi = WeatherApi(
    userAgent: 'Fishcast-App',
    temperatureUnit: TemperatureUnit.celsius,
  );
  final _cacheService = CacheService();

  /// Fetch 7-day weather forecast for specified coordinates (with caching)
  Future<List<WeatherData>> getWeeklyForecast({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    // Check cache first unless force refresh
    if (!forceRefresh) {
      final cacheKey = '${CacheService.weeklyForecastKey}_${latitude}_$longitude';
      final cached = await _cacheService.getCache(
        cacheKey,
        CacheService.forecastCacheDuration,
      );

      if (cached != null) {
        return _parseForecastFromCache(cached);
      }
    }

    try {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 6));

      final response = await _weatherApi.request(
        locations: {
          OpenMeteoLocation(
            latitude: latitude,
            longitude: longitude,
            startDate: now,
            endDate: endDate,
          ),
        },
        daily: {
          WeatherDaily.temperature_2m_max,
          WeatherDaily.temperature_2m_min,
          WeatherDaily.weather_code,
          WeatherDaily.precipitation_sum,
          WeatherDaily.wind_speed_10m_max,
        },
      );

      final segment = response.segments.first;
      final tempMaxData = segment.dailyData[WeatherDaily.temperature_2m_max]!;
      final tempMinData = segment.dailyData[WeatherDaily.temperature_2m_min]!;
      final weatherCodeData = segment.dailyData[WeatherDaily.weather_code]!;
      final precipData = segment.dailyData[WeatherDaily.precipitation_sum]!;
      final windSpeedData = segment.dailyData[WeatherDaily.wind_speed_10m_max]!;

      final List<WeatherData> forecasts = [];
      final dates = tempMaxData.values.keys.toList();

      for (final date in dates) {
        forecasts.add(WeatherData(
          date: date,
          temperatureMax: tempMaxData.values[date]!.toDouble(),
          temperatureMin: tempMinData.values[date]!.toDouble(),
          weatherCode: weatherCodeData.values[date]!.toInt(),
          precipitation: precipData.values[date]!.toDouble(),
          windSpeed: windSpeedData.values[date]!.toDouble(),
        ));
      }

      // Cache the forecast data
      final cacheKey = '${CacheService.weeklyForecastKey}_${latitude}_$longitude';
      await _cacheService.saveCache(cacheKey, {
        'forecasts': forecasts.map((f) => {
          'date': f.date.toIso8601String(),
          'temperatureMax': f.temperatureMax,
          'temperatureMin': f.temperatureMin,
          'weatherCode': f.weatherCode,
          'precipitation': f.precipitation,
          'windSpeed': f.windSpeed,
        }).toList(),
      });

      return forecasts;
    } catch (e) {
      throw Exception('Failed to load weather forecast: $e');
    }
  }

  List<WeatherData> _parseForecastFromCache(Map<String, dynamic> cached) {
    final forecastsList = cached['forecasts'] as List;
    return forecastsList.map((f) {
      return WeatherData(
        date: DateTime.parse(f['date']),
        temperatureMax: f['temperatureMax'].toDouble(),
        temperatureMin: f['temperatureMin'].toDouble(),
        weatherCode: f['weatherCode'],
        precipitation: f['precipitation'].toDouble(),
        windSpeed: f['windSpeed'].toDouble(),
      );
    }).toList();
  }

  /// Fetch current weather for specified coordinates (with caching)
  Future<CurrentWeather> getCurrentWeather({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    // Check cache first unless force refresh
    if (!forceRefresh) {
      final cacheKey = '${CacheService.currentWeatherKey}_${latitude}_$longitude';
      final cached = await _cacheService.getCache(
        cacheKey,
        CacheService.weatherCacheDuration,
      );

      if (cached != null) {
        return CurrentWeather(
          temperature: cached['temperature'].toDouble(),
          weatherCode: cached['weatherCode'],
          windSpeed: cached['windSpeed'].toDouble(),
          precipitation: cached['precipitation'].toDouble(),
          time: DateTime.parse(cached['time']),
        );
      }
    }

    try {
      final response = await _weatherApi.request(
        locations: {
          OpenMeteoLocation(
            latitude: latitude,
            longitude: longitude,
          ),
        },
        current: {
          WeatherCurrent.temperature_2m,
          WeatherCurrent.weather_code,
          WeatherCurrent.wind_speed_10m,
          WeatherCurrent.precipitation,
        },
      );

      final segment = response.segments.first;
      
      // Extract current weather data - handle both num and ParameterValue types
      dynamic tempData = segment.currentData[WeatherCurrent.temperature_2m]!;
      dynamic weatherCodeData = segment.currentData[WeatherCurrent.weather_code]!;
      dynamic windSpeedData = segment.currentData[WeatherCurrent.wind_speed_10m]!;
      dynamic precipData = segment.currentData[WeatherCurrent.precipitation]!;

      // Convert to numeric values
      final temp = (tempData is num) ? tempData.toDouble() : double.parse(tempData.toString());
      final code = (weatherCodeData is num) ? weatherCodeData.toInt() : int.parse(weatherCodeData.toString());
      final wind = (windSpeedData is num) ? windSpeedData.toDouble() : double.parse(windSpeedData.toString());
      final precip = (precipData is num) ? precipData.toDouble() : double.parse(precipData.toString());

      final weather = CurrentWeather(
        temperature: temp,
        weatherCode: code,
        windSpeed: wind,
        precipitation: precip,
        time: DateTime.now(),
      );

      // Cache the weather data
      final cacheKey = '${CacheService.currentWeatherKey}_${latitude}_$longitude';
      await _cacheService.saveCache(cacheKey, {
        'temperature': weather.temperature,
        'weatherCode': weather.weatherCode,
        'windSpeed': weather.windSpeed,
        'precipitation': weather.precipitation,
        'time': weather.time.toIso8601String(),
      });

      return weather;
    } catch (e) {
      throw Exception('Failed to load current weather: $e');
    }
  }
}
