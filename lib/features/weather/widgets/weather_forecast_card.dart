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
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final titleFontSize = screenWidth < 360 ? 16.0 : 18.0;
        final padding = screenWidth < 360 ? 12.0 : 16.0;

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
            minHeight: screenHeight * 0.3,
            maxHeight: screenHeight * 0.65,
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Weather Forecast",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: padding * 0.75),
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
      final screenWidth = MediaQuery.of(context).size.width;
      final iconSize = screenWidth < 360 ? 40.0 : 48.0;
      final fontSize = screenWidth < 360 ? 13.0 : 14.0;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white70, size: iconSize),
            const SizedBox(height: 16),
            Text(
              'Failed to load forecast',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
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
            final screenWidth = MediaQuery.of(context).size.width;
            final iconSize = screenWidth < 360 ? 36.0 : 40.0;
            final fontSize = screenWidth < 360 ? 13.0 : 14.0;
            final smallFontSize = screenWidth < 360 ? 11.0 : 12.0;
            
            final widgets = <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(iconSize / 2),
                  ),
                  child: Center(
                    child: Icon(
                      _getWeatherIcon(forecast.weatherCode),
                      color: Colors.white,
                      size: iconSize * 0.6,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        index == 0 ? 'Today' : forecast.dayOfWeek,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: fontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '${forecast.temperatureMax.round()}° / ${forecast.temperatureMin.round()}°',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: screenWidth * 0.2,
                  child: Text(
                    forecast.condition,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: smallFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
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
