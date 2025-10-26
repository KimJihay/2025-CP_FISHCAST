import 'package:fishcast/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';
import '../../models/location_model.dart';

class WeatherCard extends StatefulWidget {
  final LocationData location;
  
  const WeatherCard({super.key, required this.location});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherService _weatherService = WeatherService();
  CurrentWeather? _currentWeather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      // Get current weather for provided location with timeout
      final weather = await _weatherService.getCurrentWeather(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ).timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('MMM dd, EEEE').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardHeight = screenWidth * 0.45; // Responsive height
        final iconSize = screenWidth * 0.35; // Responsive icon area
        final sunSize = screenWidth * 0.22; // Responsive sun size
        final cloudSize = screenWidth * 0.3; // Responsive cloud size
        final fontSize = screenWidth < 360 ? 12.0 : 14.0;
        final tempFontSize = screenWidth < 360 ? 40.0 : 48.0;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF03457F), Color(0xFF009BDD)],
            ),
          ),
          height: cardHeight.clamp(140.0, 200.0),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 8,
            ),
            child: Row(
              children: [
                // Weather icon section
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: iconSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: sunSize * 1.3,
                          height: sunSize * 1.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFEE9A)
                                    .withValues(alpha: 0.8),
                                spreadRadius: 0.8,
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        // Sun SVG
                        SvgPicture.asset(
                          "assets/weather_card/sun.svg",
                          width: sunSize,
                          height: sunSize,
                        ),
                        // Clouds SVG
                        Positioned(
                          bottom: 0,
                          child: SvgPicture.asset(
                            "assets/weather_card/clouds.svg",
                            width: cloudSize,
                            height: cloudSize * 0.56,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Weather info section
                Flexible(
                  flex: 3,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.location.displayName,
                                style: TextStyle(
                                  color: kBackgroundColor,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Urbanist',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _getFormattedDate(),
                                style: TextStyle(
                                  color: kBackgroundColor,
                                  fontSize: fontSize - 2,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Urbanist',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _currentWeather != null
                                      ? "${_currentWeather!.temperature.round()}°"
                                      : "25°",
                                  style: TextStyle(
                                    color: kBackgroundColor,
                                    fontSize: tempFontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _currentWeather != null
                                    ? "${_currentWeather!.fahrenheit.round()} Fahrenheit"
                                    : "77 Fahrenheit",
                                style: TextStyle(
                                  color: kBackgroundColor,
                                  fontSize: fontSize - 2,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Urbanist',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
