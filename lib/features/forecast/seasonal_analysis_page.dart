import 'package:fishcast/core/models/seasonal_analysis_model.dart';
import 'package:fishcast/core/services/seasonal_analysis_service.dart';
import 'package:fishcast/core/utils/constants.dart';
import 'package:fishcast/core/widgets/bar/appbar.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:flutter/material.dart';

class SeasonalAnalysisPage extends StatefulWidget {
  final String? initialFishType;

  const SeasonalAnalysisPage({super.key, this.initialFishType});

  @override
  State<SeasonalAnalysisPage> createState() => _SeasonalAnalysisPageState();
}

class _SeasonalAnalysisPageState extends State<SeasonalAnalysisPage> {
  final SeasonalAnalysisService _seasonalService = SeasonalAnalysisService();
  
  bool _isLoading = true;
  bool _showOverall = true;
  String? _selectedFish;
  SeasonalAnalysis? _seasonalData;
  FishSeasonalData? _fishData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialFishType != null) {
      _showOverall = false;
      _selectedFish = widget.initialFishType;
      _loadFishSeasonalData();
    } else {
      _loadOverallSeasonalData();
    }
  }

  Future<void> _loadOverallSeasonalData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _seasonalService.getSeasonalAnalysis(
        forceRefresh: forceRefresh,
      );
      
      if (mounted) {
        setState(() {
          _seasonalData = data;
          _isLoading = false;
          if (data == null) {
            _errorMessage = 'Unable to load seasonal data. Please check your connection.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading seasonal data: $e';
        });
      }
    }
  }

  Future<void> _loadFishSeasonalData({bool forceRefresh = false}) async {
    if (_selectedFish == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fishKey = _seasonalService.displayNameToApiId(_selectedFish!);
      final data = await _seasonalService.getFishSeasonalAnalysis(
        fishKey,
        forceRefresh: forceRefresh,
      );
      
      if (mounted) {
        setState(() {
          _fishData = data;
          _isLoading = false;
          if (data == null) {
            _errorMessage = 'Unable to load seasonal data for this fish.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading fish seasonal data: $e';
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const AppbarWidget()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : _errorMessage != null
              ? _buildErrorWidget()
              : _showOverall
                  ? _buildOverallView()
                  : _buildFishView(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kSecondaryTextColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_showOverall) {
                  _loadOverallSeasonalData(forceRefresh: true);
                } else {
                  _loadFishSeasonalData(forceRefresh: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallView() {
    if (_seasonalData == null) {
      return const SizedBox.shrink();
    }

    final overall = _seasonalData!.overall;
    if (overall.monthlyData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No seasonal data available yet.',
            style: TextStyle(color: kSecondaryTextColor),
          ),
        ),
      );
    }
    
    // Safely derive month labels for charts (avoid substring errors)
    final monthLabels = overall.monthlyData.map((m) {
      final name = m.monthName;
      if (name.length >= 3) return name.substring(0, 3);
      if (name.isNotEmpty) return name;
      return 'M${m.monthNumber}';
    }).toList();
    while (monthLabels.length < 12) {
      monthLabels.add('');
    }
    
    // Prepare chart data
    final priceValues = overall.monthlyData.map((m) => m.avgPrice).toList();
    final supplyValues = overall.monthlyData
        .map((m) => m.totalSupply ?? m.avgSupply)
        .toList();

    final priceData = createChartData(
      yValues: priceValues,
      labels: monthLabels,
    );

    final supplyData = createChartData(
      yValues: supplyValues,
      labels: monthLabels,
    );

    // Compute y-axis ranges for better chart stability
    double computeMin(List<double> values) =>
        values.reduce((a, b) => a < b ? a : b);
    double computeMax(List<double> values) =>
        values.reduce((a, b) => a > b ? a : b);

    final minPrice = computeMin(priceValues);
    final maxPrice = computeMax(priceValues);
    final priceRange = (maxPrice - minPrice).abs();
    final priceMinY = (minPrice - priceRange * 0.1).clamp(0, double.infinity);
    final priceMaxY = maxPrice + priceRange * 0.1;

    final minSupply = computeMin(supplyValues);
    final maxSupply = computeMax(supplyValues);
    final supplyRange = (maxSupply - minSupply).abs();
    final supplyMinY = (minSupply - supplyRange * 0.1).clamp(0, double.infinity);
    final supplyMaxY = maxSupply + supplyRange * 0.1;

    return RefreshIndicator(
      onRefresh: () => _loadOverallSeasonalData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Peak/Low Summary
            _buildPeakLowCard(
              'Price Trends',
              overall.peakPriceMonth,
              '₱${overall.peakPriceValue.toStringAsFixed(2)}/kg',
              overall.lowPriceMonth,
              '₱${overall.lowPriceValue.toStringAsFixed(2)}/kg',
              Icons.trending_up,
            ),
            
            const SizedBox(height: 16),
            
            _buildPeakLowCard(
              'Supply Trends',
              overall.peakSupplyMonth,
              '${(overall.peakSupplyValue / 1000).toStringAsFixed(1)}k kg',
              overall.lowSupplyMonth,
              '${(overall.lowSupplyValue / 1000).toStringAsFixed(1)}k kg',
              Icons.inventory_2,
            ),
            
            const SizedBox(height: 24),
            
            // Price Chart
            _buildChartCard(
              'Monthly Average Prices',
              LinechartWidget(
                data: priceData,
                axisConfig: AxisConfig(
                  customLabels: monthLabels,
                  minX: 0,
                  maxX: 11,
                  minY: priceMinY.toDouble(),
                  maxY: priceMaxY.toDouble(),
                  interval: priceRange > 0 ? priceRange / 4 : 1,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Supply Chart
            _buildChartCard(
              'Monthly Total Supply',
              LinechartWidget(
                data: supplyData,
                axisConfig: AxisConfig(
                  customLabels: monthLabels,
                  minX: 0,
                  maxX: 11,
                  minY: supplyMinY.toDouble(),
                  maxY: supplyMaxY.toDouble(),
                  interval: supplyRange > 0 ? supplyRange / 4 : 1,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // View by Fish Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showFishSelectionDialog();
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Specific Fish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFishView() {
    if (_fishData == null) return const SizedBox.shrink();

    final fish = _fishData!;
    if (fish.monthlyData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No seasonal data available for this fish yet.',
            style: TextStyle(color: kSecondaryTextColor),
          ),
        ),
      );
    }
    
    // Safely derive month labels for charts (avoid substring errors)
    final monthLabels = fish.monthlyData.map((m) {
      final name = m.monthName;
      if (name.length >= 3) return name.substring(0, 3);
      if (name.isNotEmpty) return name;
      return 'M${m.monthNumber}';
    }).toList();
    while (monthLabels.length < 12) {
      monthLabels.add('');
    }
    
    // Prepare chart data
    final priceValues = fish.monthlyData.map((m) => m.avgPrice).toList();
    final supplyValues = fish.monthlyData.map((m) => m.avgSupply).toList();

    final priceData = createChartData(
      yValues: priceValues,
      labels: monthLabels,
    );

    final supplyData = createChartData(
      yValues: supplyValues,
      labels: monthLabels,
    );

    double computeMin(List<double> values) =>
        values.reduce((a, b) => a < b ? a : b);
    double computeMax(List<double> values) =>
        values.reduce((a, b) => a > b ? a : b);

    final minPrice = computeMin(priceValues);
    final maxPrice = computeMax(priceValues);
    final priceRange = (maxPrice - minPrice).abs();
    final minPriceY = (minPrice - priceRange * 0.1).clamp(0, double.infinity);
    final maxPriceY = maxPrice + priceRange * 0.1;

    final minSupply = computeMin(supplyValues);
    final maxSupply = computeMax(supplyValues);
    final supplyRange = (maxSupply - minSupply).abs();
    final minSupplyY = (minSupply - supplyRange * 0.1).clamp(0, double.infinity);
    final maxSupplyY = maxSupply + supplyRange * 0.1;

    return RefreshIndicator(
      onRefresh: () => _loadFishSeasonalData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fish name header
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showOverall = true;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    fish.fishName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showFishSelectionDialog,
                  icon: const Icon(Icons.change_circle),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Peak/Low Summary
            _buildPeakLowCard(
              'Price Trends',
              fish.peakPriceMonth,
              '₱${fish.peakPriceValue.toStringAsFixed(2)}/kg',
              fish.lowPriceMonth,
              '₱${fish.lowPriceValue.toStringAsFixed(2)}/kg',
              Icons.trending_up,
            ),
            
            const SizedBox(height: 16),
            
            _buildPeakLowCard(
              'Supply Trends',
              fish.peakSupplyMonth,
              '${fish.peakSupplyValue.toStringAsFixed(0)} kg',
              fish.lowSupplyMonth,
              '${fish.lowSupplyValue.toStringAsFixed(0)} kg',
              Icons.inventory_2,
            ),
            
            const SizedBox(height: 16),
            
            // Volatility Card
            _buildVolatilityCard(fish),
            
            const SizedBox(height: 24),
            
            // Price Chart
            _buildChartCard(
              'Monthly Average Prices',
              LinechartWidget(
                data: priceData,
                axisConfig: AxisConfig(
                  customLabels: monthLabels,
                  minX: 0,
                  maxX: 11,
                  minY: minPriceY.toDouble(),
                  maxY: maxPriceY.toDouble(),
                  interval: priceRange > 0 ? priceRange / 4 : 1,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Supply Chart
            _buildChartCard(
              'Monthly Average Supply (kg)',
              LinechartWidget(
                data: supplyData,
                axisConfig: AxisConfig(
                  customLabels: monthLabels,
                  minX: 0,
                  maxX: 11,
                  minY: minSupplyY.toDouble(),
                  maxY: maxSupplyY.toDouble(),
                  interval: supplyRange > 0 ? supplyRange / 4 : 1,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.insights, color: kPrimaryColor, size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Market Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kForegroundColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Seasonal patterns across all fish types',
                    style: TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakLowCard(
    String title,
    String peakMonth,
    String peakValue,
    String lowMonth,
    String lowValue,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kForegroundColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Peak',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        peakMonth,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kForegroundColor,
                        ),
                      ),
                      Text(
                        peakValue,
                        style: const TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Low',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lowMonth,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kForegroundColor,
                        ),
                      ),
                      Text(
                        lowValue,
                        style: const TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolatilityCard(FishSeasonalData fish) {
    // Determine volatility level
    String getPriceVolatilityLevel(double volatility) {
      if (volatility < 10) return 'Low';
      if (volatility < 20) return 'Moderate';
      return 'High';
    }

    Color getPriceVolatilityColor(double volatility) {
      if (volatility < 10) return Colors.green;
      if (volatility < 20) return Colors.orange;
      return Colors.red;
    }

    final priceLevel = getPriceVolatilityLevel(fish.priceVolatility);
    final priceColor = getPriceVolatilityColor(fish.priceVolatility);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: kPrimaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Price Volatility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kForegroundColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Volatility Level',
                        style: TextStyle(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: priceColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: priceColor, width: 1),
                            ),
                            child: Text(
                              priceLevel,
                              style: TextStyle(
                                color: priceColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Std. Deviation',
                      style: TextStyle(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '±₱${fish.priceVolatility.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kForegroundColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Price fluctuations show $priceLevel variability across months',
              style: const TextStyle(
                color: kSecondaryTextColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kForegroundColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  void _showFishSelectionDialog() {
    if (_seasonalData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading fish list...')),
      );
      return;
    }

    final fishList = _seasonalData!.byFish.values.map((f) => f.fishName).toList();
    fishList.sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Fish Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: fishList.length,
                  itemBuilder: (context, index) {
                    final fishName = fishList[index];
                    return ListTile(
                      leading: const Icon(Icons.water_drop, color: kPrimaryColor),
                      title: Text(fishName),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedFish = fishName;
                          _showOverall = false;
                        });
                        _loadFishSeasonalData();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
