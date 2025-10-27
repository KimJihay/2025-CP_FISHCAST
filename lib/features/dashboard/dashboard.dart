import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/cards/moon_phases_card.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:fishcast/core/services/location_service.dart';
import 'package:fishcast/core/services/fish_type_service.dart';
import 'package:fishcast/core/services/fish_forecast_service.dart';
import 'package:fishcast/core/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/cards/weather_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final LocationService _locationService = LocationService();
  final FishTypeService _fishTypeService = FishTypeService();
  final FishForecastService _forecastService = FishForecastService();
  
  LocationData? _sharedLocation;
  bool _isLoadingLocation = true;
  
  List<String> fishTypes = [];
  bool _isLoadingFishTypes = true;
  String dropdownValue = "Galunggong";
  
  List<Map<String, dynamic>> _highestPriceFish = [];
  List<Map<String, dynamic>> _lowestPriceFish = [];
  bool _isLoadingPriceLists = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadFishTypes();
    _loadPriceLists();
  }

  /// Load highest and lowest price fish from forecasts
  Future<void> _loadPriceLists() async {
    if (mounted) {
      setState(() {
        _isLoadingPriceLists = true;
      });
    }

    try {
      final allForecasts = await _forecastService.getAllForecasts();

      if (allForecasts == null || allForecasts.isEmpty) {
        if (mounted) {
          setState(() {
            _highestPriceFish = [];
            _lowestPriceFish = [];
            _isLoadingPriceLists = false;
          });
        }
        return;
      }

      // Build list of fish with their prices
      final fishPriceList = <Map<String, dynamic>>[];

      for (final entry in allForecasts.entries) {
        final fishType = entry.key;
        final forecast = entry.value;

        if (forecast.forecast.isNotEmpty) {
          final latestPrice = forecast.forecast.last.price;
          final previousPrice = forecast.forecast.length > 1
              ? forecast.forecast[forecast.forecast.length - 2].price
              : latestPrice;

          final changePercentage = previousPrice != 0
              ? ((latestPrice - previousPrice) / previousPrice) * 100
              : 0.0;

          final displayName =
              _forecastService.apiIdToDisplayName(fishType);

          fishPriceList.add({
            'fishName': displayName,
            'price': latestPrice,
            'changePercentage': changePercentage,
            'fishType': fishType,
          });
        }
      }

      // Sort for highest price (descending)
      final highest = List<Map<String, dynamic>>.from(fishPriceList)
        ..sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));

      // Sort for lowest price (ascending)
      final lowest = List<Map<String, dynamic>>.from(fishPriceList)
        ..sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));

      if (mounted) {
        setState(() {
          _highestPriceFish = highest.take(5).toList();
          _lowestPriceFish = lowest.take(5).toList();
          _isLoadingPriceLists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _highestPriceFish = [];
          _lowestPriceFish = [];
          _isLoadingPriceLists = false;
        });
      }
    }
  }

  /// Load fish types from API or use defaults
  Future<void> _loadFishTypes() async {
    try {
      final types = await _fishTypeService.getFishTypeNames();
      
      if (mounted) {
        setState(() {
          fishTypes = types;
          _isLoadingFishTypes = false;
          // Ensure dropdownValue is valid
          if (!fishTypes.contains(dropdownValue) && fishTypes.isNotEmpty) {
            dropdownValue = fishTypes.first;
          }
        });
      }
    } catch (e) {
      // Fallback to default fish types
      if (mounted) {
        setState(() {
          fishTypes = _fishTypeService.getDefaultFishTypeNames();
          _isLoadingFishTypes = false;
          if (!fishTypes.contains(dropdownValue) && fishTypes.isNotEmpty) {
            dropdownValue = fishTypes.first;
          }
        });
      }
    }
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
      final location = await _locationService.getLocationWithCache().timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _sharedLocation = location;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
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

  void _onFishTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        dropdownValue = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenWidth < 360 ? 14.0 : 16.0;
    final chartHeight = (screenHeight * 0.25).clamp(180.0, 250.0);

    return Scaffold(
      appBar: AppBar(title: const AppbarWidget()),
      body: _isLoadingLocation || _isLoadingFishTypes
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RefreshIndicator(
                  onRefresh: _loadLocation,
                  child: ListView(
                    children: [
                      WeatherCard(location: _sharedLocation!),
                      const SizedBox(height: 5),
                      MoonPhasesCard(location: _sharedLocation!),
                      SizedBox(height: 20),
                      Text(
                        "Highest Price Fish (per kg)",
                        style: TextStyle(
                          color: kForegroundColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_isLoadingPriceLists)
                        Center(
                          child: CircularProgressIndicator(color: kSecondaryColor),
                        )
                      else if (_highestPriceFish.isEmpty)
                        Center(
                          child: Text(
                            'No price data available',
                            style: TextStyle(color: kSecondaryTextColor),
                          ),
                        )
                      else
                        ...List.generate(_highestPriceFish.length, (index) {
                          final fishData = _highestPriceFish[index];
                          final changePercentage =
                              fishData['changePercentage'] as double;
                          final price = fishData['price'] as double;
                          final fishName = fishData['fishName'] as String;

                          final widgets = <Widget>[
                            ListTile(
                              leading: Text("${index + 1}"),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      fishName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("₱${price.toStringAsFixed(2)}")
                                ],
                              ),
                              trailing: Text(
                                "${changePercentage > 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: changePercentage > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ];
                          if (index < _highestPriceFish.length - 1) {
                            widgets.add(const Divider());
                          }
                          return widgets;
                        }).expand((x) => x),
                      SizedBox(height: 27),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("View More"),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 27),
                      Text(
                        "Lowest Price Fish (per kg)",
                        style: TextStyle(
                          color: kForegroundColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_isLoadingPriceLists)
                        Center(
                          child: CircularProgressIndicator(color: kSecondaryColor),
                        )
                      else if (_lowestPriceFish.isEmpty)
                        Center(
                          child: Text(
                            'No price data available',
                            style: TextStyle(color: kSecondaryTextColor),
                          ),
                        )
                      else
                        ...List.generate(_lowestPriceFish.length, (index) {
                          final fishData = _lowestPriceFish[index];
                          final changePercentage =
                              fishData['changePercentage'] as double;
                          final price = fishData['price'] as double;
                          final fishName = fishData['fishName'] as String;

                          final widgets = <Widget>[
                            ListTile(
                              leading: Text("${index + 1}"),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      fishName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("₱${price.toStringAsFixed(2)}")
                                ],
                              ),
                              trailing: Text(
                                "${changePercentage > 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: changePercentage > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ];
                          if (index < _lowestPriceFish.length - 1) {
                            widgets.add(const Divider());
                          }
                          return widgets;
                        }).expand((x) => x),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("View More"),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 27),
                      Text(
                        "Predict Supply Volume",
                        style: TextStyle(
                          color: kForegroundColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Next 7d",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: screenWidth * 0.2,
                                maxWidth: screenWidth * 0.3,
                                minHeight: 22,
                                maxHeight: 28,
                              ),
                              padding: const EdgeInsets.only(left: 8, right: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(
                                  color: kPrimaryStrokeColor,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButton<String>(
                                isDense: true,
                                isExpanded: true,
                                value: dropdownValue,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: kSecondaryTextColor,
                                  size: 20,
                                ),
                                iconSize: 20,
                                elevation: 2,
                                style: const TextStyle(
                                  color: kSecondaryTextColor,
                                  fontSize: 12,
                                ),
                                dropdownColor: Colors.white,
                                underline: const SizedBox(),
                                onChanged: _onFishTypeChanged,
                                items: fishTypes.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      SizedBox(
                        height: chartHeight,
                        width: double.infinity,
                        child: LinechartWidget(data: pricePoints),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
