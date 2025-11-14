import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:fishcast/core/services/fish_type_service.dart';
import 'package:fishcast/core/services/fish_forecast_service.dart';
import 'package:fishcast/core/models/fish_forecast_model.dart';
import 'package:fishcast/features/forecast/seasonal_analysis_page.dart';
import 'package:flutter/material.dart';

class ForecastPage extends StatefulWidget {
  const ForecastPage({super.key});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  final FishTypeService _fishTypeService = FishTypeService();
  final FishForecastService _forecastService = FishForecastService();
  
  List<String> fishTypes = [];
  bool _isLoadingFishTypes = true;
  bool _isLoadingForecast = false;
  bool _isLoadingTopFish = true;
  String dropdownValue = "Galunggong (Round Scad)";
  FishForecast? _currentForecast;
  String? _errorMessage;
  List<Map<String, dynamic>> _topFishByPrice = [];

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
    _loadForecast();
    _loadTopFishByPrice();
  }

  /// Load top 5 fish sorted by price
  Future<void> _loadTopFishByPrice() async {
    if (mounted) {
      setState(() {
        _isLoadingTopFish = true;
      });
    }

    try {
      final allForecasts = await _forecastService.getAllForecasts();

      if (allForecasts == null || allForecasts.isEmpty) {
        if (mounted) {
          setState(() {
            _topFishByPrice = [];
            _isLoadingTopFish = false;
          });
        }
        return;
      }

      // Build list of fish with their prices
      final fishPriceList = <Map<String, dynamic>>[];

      for (final entry in allForecasts.entries) {
        final fishType = entry.key; // API identifier like 'galunggong_round_scad'
        final forecast = entry.value;

        if (forecast.forecast.isNotEmpty) {
          // Get the latest price (last date in forecast)
          final latestPrice = forecast.forecast.last.price;
          // Get previous price for percentage change calculation (if available)
          final previousPrice = forecast.forecast.length > 1
              ? forecast.forecast[forecast.forecast.length - 2].price
              : latestPrice;

          // Calculate percentage change
          final changePercentage = previousPrice != 0
              ? ((latestPrice - previousPrice) / previousPrice) * 100
              : 0.0;

          // Convert API identifier to display name
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

      // Sort by price (highest to lowest)
      fishPriceList.sort(
          (a, b) => (b['price'] as num).compareTo(a['price'] as num));

      // Take top 5
      final topFive =
          fishPriceList.take(5).toList();

      if (mounted) {
        setState(() {
          _topFishByPrice = topFive;
          _isLoadingTopFish = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _topFishByPrice = [];
          _isLoadingTopFish = false;
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

  /// Load forecast data for the selected fish type
  Future<void> _loadForecast() async {
    if (mounted) {
      setState(() {
        _isLoadingForecast = true;
        _errorMessage = null;
      });
    }

    try {
      // Convert display name to API identifier
      final apiId = _forecastService.fishNameToApiId(dropdownValue);
      final forecast = await _forecastService.getForecast(apiId);

      if (mounted) {
        setState(() {
          _currentForecast = forecast;
          _isLoadingForecast = false;
          if (forecast == null) {
            _errorMessage = 'Unable to load forecast. Please try again later.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingForecast = false;
          _errorMessage = 'Error loading forecast: $e';
        });
      }
    }
  }

  void _onFishTypeChanged(String? newValue) {
    if (newValue != null && newValue != dropdownValue) {
      setState(() {
        dropdownValue = newValue;
      });
      // Load new forecast for selected fish
      _loadForecast();
    }
  }

  /// Build the forecast chart widget
  Widget _buildForecastChart() {
    // Loading state
    if (_isLoadingForecast) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kSecondaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading forecast...',
              style: TextStyle(color: kSecondaryTextColor),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadForecast,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // No data state
    if (_currentForecast == null || _currentForecast!.forecast.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No forecast data available',
              style: TextStyle(color: kSecondaryTextColor),
            ),
          ],
        ),
      );
    }

    // Convert forecast data to chart points
    final forecastData = _currentForecast!.forecast;
    
    // Create date labels for the forecast (e.g., "Mon 27", "Tue 28")
    final dateLabels = forecastData.map((point) {
      final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][point.date.weekday % 7];
      return '$weekday ${point.date.day}';
    }).toList();
    
    // Create chart data with sequential x values (0, 1, 2, 3, 4, 5, 6)
    final pricePoints = List.generate(forecastData.length, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: forecastData[index].price,
        label: dateLabels[index],
      );
    });
    
    // Calculate appropriate y-axis range
    final prices = forecastData.map((p) => p.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;
    final yMin = (minPrice - priceRange * 0.1).clamp(0, double.infinity).toDouble();
    final yMax = (maxPrice + priceRange * 0.1).toDouble();
    
    return LinechartWidget(
      data: pricePoints,
      lineConfig: const LineConfig(
        color: Colors.blue,
        label: 'Price',
        lineWidth: 3.0,
        showDots: true,
        showArea: true,
      ),
      axisConfig: AxisConfig(
        customLabels: dateLabels,
        minX: 0,
        maxX: (forecastData.length - 1).toDouble(),
        minY: yMin,
        maxY: yMax,
        interval: priceRange > 100 ? 50 : 20,
        yAxisLabel: 'Price (₱)',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingFishTypes) {
      return Scaffold(
        appBar: AppBar(title: const AppbarWidget()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const AppbarWidget()),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SeasonalAnalysisPage(),
              ),
            );
          },
          backgroundColor: kSecondaryColor,
          icon: const Icon(Icons.insights),
          label: const Text('Seasonal Trends'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final chartHeight = screenHeight * 0.25; // 25% of screen height

            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: MediaQuery.of(context).padding.top + 16,
              ),
              children: [
                Row(
                  children: [
                    Text(
                      "Market Forecast",
                      style: TextStyle(
                        color: kForegroundColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Price Forecast",
                  style: TextStyle(
                    color: kForegroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Next 7d",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 83.5,
                      height: 22,
                      child: Container(
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
                const SizedBox(height: 14),
                // Chart or Loading/Error state
                Container(
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxHeight: chartHeight.clamp(200, 400),
                  ),
                  width: double.infinity,
                  child: _buildForecastChart(),
                ),
                SizedBox(height: 15),
                Text(
                  "Fish by Price",
                  style: TextStyle(
                    color: kForegroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Urbanist',
                  ),
                ),
                SizedBox(height: 16),
                if (_isLoadingTopFish)
                  Center(
                    child: CircularProgressIndicator(color: kSecondaryColor),
                  )
                else if (_topFishByPrice.isEmpty)
                  Center(
                    child: Text(
                      'No fish price data available',
                      style: TextStyle(color: kSecondaryTextColor),
                    ),
                  )
                else
                  ...List.generate(_topFishByPrice.length, (index) {
                    final fishData = _topFishByPrice[index];
                    final changePercentage =
                        fishData['changePercentage'] as double;
                    final price = fishData['price'] as double;
                    final fishName = fishData['fishName'] as String;

                    final widgets = <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  fishName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "₱${price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: changePercentage > 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${changePercentage > 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: changePercentage > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                    if (index < _topFishByPrice.length - 1) {
                      widgets.add(
                        const Divider(height: 1, indent: 16, endIndent: 16),
                      );
                    }
                    return widgets;
                  }).expand((x) => x),
              ],
            );
          },
        ),
      ),
    );
  }
}
