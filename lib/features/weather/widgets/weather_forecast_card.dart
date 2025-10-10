import 'package:flutter/material.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/models/location_model.dart';

class WeatherForecastCard extends StatefulWidget {
  final LocationData location;
  
  const WeatherForecastCard({super.key, required this.location});

  @override
  State<WeatherForecastCard> createState() => _WeatherForecastCardState();
}

class _WeatherForecastCardState extends State<WeatherForecastCard> {
  final WeatherService _weatherService = WeatherService();
  List<WeatherData>? _forecasts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    try {
      // Get weather forecast for provided location with timeout
      final forecasts = await _weatherService.getWeeklyForecast(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _forecasts = forecasts;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemHeight = 60.0;
        final headerHeight = 70.0;
        final paddingHeight = 32.0;
        final calculatedHeight =
            (itemHeight * 7) + headerHeight + paddingHeight;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF03457F), Color(0xFF009BDD)],
            ),
          ),
          constraints: BoxConstraints(
            minHeight: calculatedHeight.clamp(300, 500),
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weather Forecast",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildForecastContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForecastContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load forecast',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadForecast,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_forecasts == null || _forecasts!.isEmpty) {
      return const Center(
        child: Text(
          'No forecast data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(_forecasts!.length, (index) {
            final forecast = _forecasts![index];
            final widgets = <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      _getWeatherIcon(forecast.weatherCode),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      index == 0 ? 'Today' : forecast.dayOfWeek,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${forecast.temperatureMax.round()}° / ${forecast.temperatureMin.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  forecast.condition,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ];
            if (index < _forecasts!.length - 1) {
              widgets.add(const Divider(color: Colors.white30, height: 1));
            }
            return widgets;
          }).expand((x) => x),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(int weatherCode) {
    // WMO Weather interpretation codes
    if (weatherCode == 0) return Icons.wb_sunny; // Clear
    if (weatherCode >= 1 && weatherCode <= 3) {
      return Icons.cloud; // Partly cloudy
    }
    if (weatherCode >= 45 && weatherCode <= 48) return Icons.foggy; // Fog
    if (weatherCode >= 51 && weatherCode <= 57) return Icons.grain; // Drizzle
    if (weatherCode >= 61 && weatherCode <= 67) return Icons.umbrella; // Rain
    if (weatherCode >= 71 && weatherCode <= 77) return Icons.ac_unit; // Snow
    if (weatherCode >= 80 && weatherCode <= 82) {
      return Icons.grain; // Rain showers
    }
    if (weatherCode >= 85 && weatherCode <= 86) {
      return Icons.ac_unit; // Snow showers
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return Icons.thunderstorm; // Thunderstorm
    }
    return Icons.help_outline; // Unknown
  }
}
