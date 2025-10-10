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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF03457F), Color(0xFF009BDD)],
        ),
      ),
      height: 169.34405517578125,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 156,
                height: 135.34405517578125,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 14.68,
                      left: 39.84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 112.66881561279297,
                            height: 106.09648895263672,
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
                          // Original SVG Sun
                          SvgPicture.asset(
                            "assets/weather_card/sun.svg",
                            width: 87.64631652832031,
                            height: 87.64631652832031,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 58.48,
                      left: 19,
                      child: SvgPicture.asset(
                        "assets/weather_card/clouds.svg",
                        width: 122.86,
                        height: 68.87,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(right: 40),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.location.displayName,
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        Text(
                          _getFormattedDate(),
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        Text(
                          _currentWeather != null
                              ? "${_currentWeather!.temperature.round()}°"
                              : "25°",
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        Text(
                          _currentWeather != null
                              ? "${_currentWeather!.fahrenheit.round()} Fahrenheit"
                              : "77 Fahrenheit",
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ],
                    ),
              const SizedBox(width: 19),
            ],
          ),
        ],
      ),
    );
  }
}
