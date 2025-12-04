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
  String dropdownValue = "Galunggong (Round Scad)";
  
  List<Map<String, dynamic>> _highestPriceFish = [];
  List<Map<String, dynamic>> _lowestPriceFish = [];
  bool _isLoadingPriceLists = true;
  String? _priceDate;
  
  Map<String, dynamic>? _supplyForecast;
  bool _isLoadingSupply = false;
  bool _isQuarterlyView = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadFishTypes();
    _loadPriceLists();
    // Load initial supply forecast with default fish type
    _loadSupplyForecast(dropdownValue);
  }

  /// Load highest and lowest price fish from actual/current prices
  Future<void> _loadPriceLists() async {
    if (mounted) {
      setState(() {
        _isLoadingPriceLists = true;
      });
    }

    try {
      final currentPrices = await _forecastService.getCurrentPrices();

      if (currentPrices == null || currentPrices['prices'] == null) {
        if (mounted) {
          setState(() {
            _highestPriceFish = [];
            _lowestPriceFish = [];
            _isLoadingPriceLists = false;
          });
        }
        return;
      }

      final pricesData = currentPrices['prices'] as Map<String, dynamic>;
      final priceDate = currentPrices['date'] as String?;

      // Build list of fish with their actual prices
      final fishPriceList = <Map<String, dynamic>>[];

      for (final entry in pricesData.entries) {
        final fishKey = entry.key;
        final fishData = entry.value as Map<String, dynamic>;

        final price = (fishData['price'] as num).toDouble();
        final fishName = fishData['fish_name'] as String? ??
            _forecastService.apiIdToDisplayName(fishKey);

        // Filter out invalid entries
        if (price > 0 && fishName.isNotEmpty) {
          fishPriceList.add({
            'fishName': fishName,
            'price': price,
            'fishType': fishKey,
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
          _priceDate = priceDate;
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

  Future<void> _loadSupplyForecast(String fishName, {bool quarterly = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingSupply = true;
        _supplyForecast = null;
      });
    }

    try {
      final apiId = _forecastService.fishNameToApiId(fishName);
      final supply = quarterly
          ? await _forecastService.getQuarterlySupplyForecast(apiId)
          : await _forecastService.getSupplyForecast(apiId);

      if (mounted) {
        setState(() {
          _supplyForecast = supply;
          _isLoadingSupply = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _supplyForecast = null;
          _isLoadingSupply = false;
        });
      }
    }
  }

  void _onFishTypeChanged(String? newValue) {
    if (newValue != null && newValue != dropdownValue) {
      setState(() {
        dropdownValue = newValue;
      });
      // Load supply forecast for selected fish
      _loadSupplyForecast(newValue, quarterly: _isQuarterlyView);
    }
  }

  void _onSupplyViewToggle(bool isQuarterly) {
    if (isQuarterly != _isQuarterlyView) {
      setState(() {
        _isQuarterlyView = isQuarterly;
      });
      _loadSupplyForecast(dropdownValue, quarterly: isQuarterly);
    }
  }

  Widget _buildSupplyChart() {
    final forecastList = _supplyForecast!['forecast'] as List<dynamic>;

    List<String> dateLabels;
    List<ChartDataPoint> supplyPoints;
    List<double> supplies;

    if (_isQuarterlyView && forecastList.length > 14) {
      // For quarterly view, aggregate by week for readability
      final weeklyData = <Map<String, dynamic>>[];
      for (int i = 0; i < forecastList.length; i += 7) {
        final weekEnd = (i + 7 < forecastList.length) ? i + 7 : forecastList.length;
        final weekItems = forecastList.sublist(i, weekEnd);
        final avgSupply = weekItems
            .map((p) => (p['supply_kg'] as num).toDouble())
            .reduce((a, b) => a + b) / weekItems.length;
        final startDate = DateTime.parse(weekItems.first['date'] as String);
        weeklyData.add({
          'date': startDate,
          'supply_kg': avgSupply,
        });
      }

      dateLabels = weeklyData.map((point) {
        final date = point['date'] as DateTime;
        return '${date.month}/${date.day}';
      }).toList();

      supplyPoints = List.generate(weeklyData.length, (index) {
        final supply = (weeklyData[index]['supply_kg'] as num).toDouble();
        return ChartDataPoint(
          x: index.toDouble(),
          y: supply,
          label: dateLabels[index],
        );
      });

      supplies = weeklyData.map((p) => (p['supply_kg'] as num).toDouble()).toList();
    } else {
      // For 7-day view, show daily data
      dateLabels = forecastList.map((point) {
        final date = DateTime.parse(point['date'] as String);
        final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            [date.weekday % 7];
        return '$weekday ${date.day}';
      }).toList();

      supplyPoints = List.generate(forecastList.length, (index) {
        final supply = (forecastList[index]['supply_kg'] as num).toDouble();
        return ChartDataPoint(
          x: index.toDouble(),
          y: supply,
          label: dateLabels[index],
        );
      });

      supplies = forecastList.map((p) => (p['supply_kg'] as num).toDouble()).toList();
    }

    // Calculate y-axis range
    final minSupply = supplies.reduce((a, b) => a < b ? a : b);
    final maxSupply = supplies.reduce((a, b) => a > b ? a : b);
    final range = maxSupply - minSupply;
    final yMin =
        (minSupply - range * 0.1).clamp(0, double.infinity).toDouble();
    final yMax = (maxSupply + range * 0.1).toDouble();

    return LinechartWidget(
      data: supplyPoints,
      lineConfig: const LineConfig(
        color: Colors.blue,
        label: 'Supply',
        lineWidth: 3.0,
        showDots: true,
        showArea: true,
      ),
      axisConfig: AxisConfig(
        customLabels: dateLabels,
        minX: 0,
        maxX: (supplyPoints.length - 1).toDouble(),
        minY: yMin,
        maxY: yMax,
        interval: range > 10000 ? 5000 : 2000,
        yAxisLabel: 'Supply (Kg)',
      ),
    );
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Highest Price Fish (per kg)",
                            style: TextStyle(
                              color: kForegroundColor,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          if (_priceDate != null)
                            Text(
                              "as of $_priceDate",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Current Market Prices",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 16),
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
                                  Text(
                                    "₱${price.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kForegroundColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ];
                          if (index < _highestPriceFish.length - 1) {
                            widgets.add(const Divider());
                          }
                          return widgets;
                        }).expand((x) => x),
                      SizedBox(height: 27),
                      const SizedBox(height: 27),
                      Text(
                        "Lowest Price Fish (per kg)",
                        style: TextStyle(
                          color: kForegroundColor,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      SizedBox(height: 16),
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
                                  Text(
                                    "₱${price.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kForegroundColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ];
                          if (index < _lowestPriceFish.length - 1) {
                            widgets.add(const Divider());
                          }
                          return widgets;
                        }).expand((x) => x),
                      const SizedBox(height: 27),
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
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _onSupplyViewToggle(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !_isQuarterlyView ? kSecondaryColor : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "7 Days",
                                    style: TextStyle(
                                      color: !_isQuarterlyView ? Colors.white : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _onSupplyViewToggle(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isQuarterlyView ? kSecondaryColor : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "Quarterly",
                                    style: TextStyle(
                                      color: _isQuarterlyView ? Colors.white : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                      if (_isLoadingSupply)
                        SizedBox(
                          height: chartHeight,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kSecondaryColor,
                            ),
                          ),
                        )
                      else if (_supplyForecast == null ||
                          (_supplyForecast!['forecast'] as List?)?.isEmpty ==
                              true)
                        SizedBox(
                          height: chartHeight,
                          child: Center(
                            child: Text(
                              'No supply data available',
                              style: TextStyle(color: kSecondaryTextColor),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: chartHeight,
                          width: double.infinity,
                          child: _buildSupplyChart(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
