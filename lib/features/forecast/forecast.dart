import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/utils/fish_image_utils.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:fishcast/core/services/fish_type_service.dart';
import 'package:fishcast/core/services/fish_forecast_service.dart';
import 'package:fishcast/core/models/fish_forecast_model.dart';
import 'package:fishcast/features/forecast/seasonal_analysis_page.dart';
import 'package:fishcast/features/forecast/forecasted_prices_page.dart';
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
  bool _isLoadingByDate = false;
  String dropdownValue = "Galunggong (Round Scad)";
  FishForecast? _currentForecast;
  String? _errorMessage;
  List<Map<String, dynamic>> _topFishByPrice = [];
  List<PriceMatch> _matchesByDate = [];
  String? _byDateError;
  String? _predictedPriceNote;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadFishTypes();
    _loadForecast();
    _loadTopFishByPrice();
    _loadPredictedTodayNote();
  }

  /// Load top 5 fish sorted by price
  Future<void> _loadTopFishByPrice() async {
    if (mounted) {
      setState(() {
        _isLoadingTopFish = true;
      });
    }

    try {
      final allForecasts = await _forecastService.getAllForecasts(
        forceRefresh: true,
      );

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

  Future<void> _loadPredictedTodayNote() async {
    try {
      final forecasts = await _forecastService.getAllForecasts(forceRefresh: true);
      if (forecasts == null || forecasts.isEmpty) return;

      final prices = <double>[];
      // Use the first forecast point (soonest) for each fish
      forecasts.forEach((_, forecast) {
        if (forecast.forecast.isEmpty) return;
        prices.add(forecast.forecast.first.price);
      });

      if (prices.isEmpty) return;

      final minP = prices.reduce((a, b) => a < b ? a : b);
      final maxP = prices.reduce((a, b) => a > b ? a : b);
      if (mounted) {
        setState(() {
          _predictedPriceNote =
              'Predicted price range today: ₱${minP.toStringAsFixed(2)} - ₱${maxP.toStringAsFixed(2)}';
        });
      }
    } catch (_) {
      // ignore
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

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // Dataset starts from 2024-01-01, allow up to 7 days in the future (forecast)
    final firstDate = DateTime(2024, 1, 1);
    final lastDate = now.add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select a date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kSecondaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kForegroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadPricesByDate() async {
    double? minPrice;
    double? maxPrice;

    try {
      if (_minPriceController.text.trim().isNotEmpty) {
        minPrice = double.parse(_minPriceController.text.trim());
      }
      if (_maxPriceController.text.trim().isNotEmpty) {
        maxPrice = double.parse(_maxPriceController.text.trim());
      }
      if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
        setState(() {
          _byDateError = 'Min price cannot be greater than max price';
          _matchesByDate = [];
        });
        return;
      }
    } catch (_) {
      setState(() {
        _byDateError = 'Prices must be numbers';
        _matchesByDate = [];
      });
      return;
    }

    setState(() {
      _isLoadingByDate = true;
      _byDateError = null;
    });

    List<PriceMatch>? matches;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedDate != null && !_selectedDate!.isAfter(today)) {
      // Historical or today — use backend /prices/by-date
      matches = await _forecastService.getPricesByDate(
        date: _selectedDate!,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    } else {
      // Future date or no date — use forecast data
      matches = await _forecastService.getForecastMatchesByPriceRange(
        minPrice: minPrice,
        maxPrice: maxPrice,
        filterDate: _selectedDate,
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoadingByDate = false;
      if (matches == null || matches.isEmpty) {
        _byDateError = _selectedDate != null
            ? 'No results for that price range on the selected date'
            : 'No results within that price range for the next 7 days';
        _matchesByDate = [];
      } else {
        _matchesByDate = matches;
      }
    });
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
    final forecastData = List<ForecastDataPoint>.from(
      _currentForecast!.forecast,
    )
      ..sort((a, b) => a.date.compareTo(b.date));
    
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
        interval: interval.toDouble(),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
                Row(
                  children: [
                    Text(
                      "Price",
                      style: TextStyle(
                        color: kForegroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Next 7 days",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showFishSelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(
                            color: kPrimaryStrokeColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Fish image thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.asset(
                                FishImageUtils.getImagePath(dropdownValue),
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    color: kPrimaryColor.withValues(alpha: 0.1),
                                    child: const Icon(Icons.phishing, size: 14, color: kPrimaryColor),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _shortenFishName(dropdownValue),
                              style: const TextStyle(
                                color: kSecondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: kSecondaryTextColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // View Full Forecast button
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForecastedPricesPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('View Full Forecast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
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
                // Price by Range (next 7 days forecasts)
                Row(
                  children: [
                    Text(
                      "Find Fish by Price",
                      style: TextStyle(
                        color: kForegroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date filter chip
                Row(
                  children: [
                    ActionChip(
                      avatar: Icon(
                        _selectedDate != null ? Icons.event : Icons.calendar_today,
                        size: 18,
                        color: _selectedDate != null ? Colors.white : kSecondaryColor,
                      ),
                      label: Text(
                        _selectedDate != null
                            ? '${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}'
                            : 'Any date',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.white : kForegroundColor,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _selectedDate != null ? kSecondaryColor : Colors.grey[100],
                      side: BorderSide(
                        color: _selectedDate != null ? kSecondaryColor : kPrimaryStrokeColor,
                      ),
                      onPressed: _pickDate,
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.black54),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 500;
                    final fieldWidth = isNarrow ? (constraints.maxWidth - 16) / 2.2 : 120.0;
                    final button = ElevatedButton(
                      onPressed: _isLoadingByDate ? null : _loadPricesByDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: _isLoadingByDate
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Search'),
                    );

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        button,
                      ],
                    );
                  },
                ),
                if (_byDateError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _byDateError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (_byDateError == null && _predictedPriceNote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _predictedPriceNote!,
                    style: TextStyle(color: kSecondaryTextColor, fontSize: 12),
                  ),
                ],
                if (_matchesByDate.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    children: _matchesByDate.map((match) {
                      // Format the date if available
                      String? dateText;
                      if (match.date != null) {
                        final d = match.date!;
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        dateText = '${months[d.month - 1]} ${d.day}, ${d.year}';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimaryStrokeColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    match.fishName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (dateText != null)
                                    Text(
                                      dateText,
                                      style: TextStyle(
                                        color: kSecondaryTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₱${match.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      "Fish by Predicted Price",
                      style: TextStyle(
                        color: kForegroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
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

  /// Show fish selection dialog with image grid
  void _showFishSelectionDialog() {
    if (fishTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading fish list...')),
      );
      return;
    }

    final sortedFishTypes = List<String>.from(fishTypes)..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.phishing,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Fish Type',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kForegroundColor,
                                ),
                              ),
                              Text(
                                'Tap a fish to view its forecast',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          color: kSecondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Fish Grid
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: sortedFishTypes.length,
                      itemBuilder: (context, index) {
                        return _buildFishCard(sortedFishTypes[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFishCard(String fishName) {
    final imagePath = FishImageUtils.getImagePath(fishName);
    final isSelected = fishName == dropdownValue;
    
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (fishName != dropdownValue) {
          setState(() {
            dropdownValue = fishName;
          });
          _loadForecast();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fish Image
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.phishing,
                          size: 40,
                          color: Colors.blue[700],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Fish Name
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.blue.withValues(alpha: 0.1) 
                      : Colors.blue.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Text(
                  _shortenFishName(fishName),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.blue[700] : kForegroundColor,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shorten fish name for display in grid cards
  String _shortenFishName(String name) {
    final parenIndex = name.indexOf('(');
    if (parenIndex > 0) {
      return name.substring(0, parenIndex).trim();
    }
    return name;
  }
}
