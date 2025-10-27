import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/cards/moon_phases_card.dart';
import 'package:fishcast/core/widgets/cards/weather_card.dart';
import 'package:fishcast/features/weather/widgets/weather_forecast_card.dart';
import 'package:fishcast/features/weather/widgets/moon_phases_card.dart';
import 'package:fishcast/core/services/location_service.dart';
import 'package:fishcast/core/models/location_model.dart';
import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final PageController _pageController = PageController();
  final LocationService _locationService = LocationService();
  int _currentPage = 0;
  LocationData? _sharedLocation;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload location when returning to this page
    if (!_isLoadingLocation && _sharedLocation?.city == "Zamboanga City") {
      _loadLocation();
    }
  }

  Future<void> _loadLocation() async {
    try {
      final location = await _locationService.getLocationWithCache()
          .timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          _sharedLocation = location;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      // Use fallback location
      if (mounted) {
        setState(() {
          _sharedLocation = LocationData(
            latitude: 6.9214,
            longitude: 122.0790,
            city: "Zamboanga City",
            country: "Philippines",
          );
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppbarWidget()),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        // First preview - Weather
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      WeatherCard(location: _sharedLocation!),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: constraints.maxHeight * 0.7,
                                        child: WeatherForecastCard(location: _sharedLocation!),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Second preview - Moon Phases
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      MoonPhasesCard(location: _sharedLocation!),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: constraints.maxHeight * 0.7,
                                        child: const MoonPhases(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 8),
            // Dot indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 10 : 6,
                  height: isActive ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
