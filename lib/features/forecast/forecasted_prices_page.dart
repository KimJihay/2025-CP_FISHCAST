import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:fishcast/core/services/fish_type_service.dart';
import 'package:fishcast/core/services/fish_forecast_service.dart';
import 'package:fishcast/core/models/fish_forecast_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastedPricesPage extends StatefulWidget {
  const ForecastedPricesPage({super.key});

  @override
  State<ForecastedPricesPage> createState() => _ForecastedPricesPageState();
}

class _ForecastedPricesPageState extends State<ForecastedPricesPage> {
  final FishTypeService _fishTypeService = FishTypeService();
  final FishForecastService _forecastService = FishForecastService();

  List<String> fishTypes = [];
  bool _isLoadingFishTypes = true;
  bool _isLoadingForecast = false;
  String dropdownValue = "Galunggong (Round Scad)";
  FishForecast? _currentForecast;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
    _loadForecast();
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
      final forecast = await _forecastService.getForecast(
        apiId,
        forceRefresh: true,
      );

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

  /// Build date range header
  Widget _buildDateRangeHeader() {
    if (_currentForecast == null || _currentForecast!.forecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final forecastData = _currentForecast!.forecast;
    final sortedData = List<ForecastDataPoint>.from(forecastData)
      ..sort((a, b) => a.date.compareTo(b.date));

    final startDate = sortedData.first.date;
    final endDate = sortedData.last.date;

    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Text(
            '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist',
            ),
          ),
        ],
      ),
    );
  }

  /// Build fish type selector
  Widget _buildFishTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Fish Type:",
            style: TextStyle(
              color: kForegroundColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist',
            ),
          ),
          SizedBox(
            width: 200,
            height: 40,
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 4),
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryStrokeColor),
                borderRadius: BorderRadius.circular(8),
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
                  fontSize: 14,
                ),
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                onChanged: _onFishTypeChanged,
                items: fishTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build forecast chart
  Widget _buildForecastChart() {
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
    final forecastData = List<ForecastDataPoint>.from(
      _currentForecast!.forecast,
    )
      ..sort((a, b) => a.date.compareTo(b.date));

    // Create date labels for the forecast (e.g., "Mon 27", "Tue 28")
    final dateLabels = forecastData.map((point) {
      final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][point.date.weekday % 7];
      return '$weekday ${point.date.day}';
    }).toList();

    // Create chart data with sequential x values
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
    final priceRange = (maxPrice - minPrice).abs();
    final adjustedRange = priceRange > 0
        ? priceRange
        : (maxPrice.abs() * 0.05).clamp(1, double.infinity);
    final yMin = (minPrice - adjustedRange * 0.1)
        .clamp(0, double.infinity)
        .toDouble();
    final yMax = (maxPrice + adjustedRange * 0.1).toDouble();
    final interval = adjustedRange > 100
        ? 50
        : adjustedRange > 20
            ? 10
            : adjustedRange > 5
                ? 2
                : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '7-Day Price Forecast',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: LinechartWidget(
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
                interval: interval.toDouble(),
                yAxisLabel: 'Price (₱)',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build forecast table
  Widget _buildForecastTable() {
    if (_currentForecast == null || _currentForecast!.forecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final forecastData = List<ForecastDataPoint>.from(
      _currentForecast!.forecast,
    )
      ..sort((a, b) => a.date.compareTo(b.date));

    final dateFormat = DateFormat('EEE, MMM d');
    final priceFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart, color: kSecondaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Daily Forecast',
                style: TextStyle(
                  color: kForegroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Urbanist',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: kPrimaryStrokeColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Forecast',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                // Data rows
                ...List.generate(forecastData.length, (index) {
                  final point = forecastData[index];
                  final isToday = index == 0;
                  final previousPrice = index > 0 ? forecastData[index - 1].price : point.price;
                  final priceChange = point.price - previousPrice;
                  final percentChange = previousPrice != 0 
                      ? (priceChange / previousPrice) * 100 
                      : 0.0;

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        color: isToday ? Colors.blue.withOpacity(0.05) : Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  if (isToday)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'TODAY',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    dateFormat.format(point.date),
                                    style: TextStyle(
                                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    priceFormat.format(point.price),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                                  if (index > 0)
                                    Text(
                                      '${priceChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: priceChange >= 0 ? Colors.green[700] : Colors.red[700],
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Icon(
                                priceChange >= 0 
                                    ? Icons.trending_up 
                                    : Icons.trending_down,
                                color: priceChange >= 0 ? Colors.green : Colors.red,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < forecastData.length - 1)
                        const Divider(height: 1, indent: 12, endIndent: 12),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppbarWidget()),
      body: _isLoadingFishTypes
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
              ),
              children: [
                // Page header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.analytics,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Forecasted Prices",
                              style: TextStyle(
                                color: kForegroundColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            Text(
                              "View predicted fish prices for the next 7 days",
                              style: TextStyle(
                                color: kSecondaryTextColor,
                                fontSize: 12,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Date range header
                _buildDateRangeHeader(),
                const SizedBox(height: 16),

                // Fish type selector
                _buildFishTypeSelector(),
                const SizedBox(height: 16),

                // Forecast chart
                _buildForecastChart(),
                const SizedBox(height: 24),

                // Forecast table
                _buildForecastTable(),
              ],
            ),
    );
  }
}
