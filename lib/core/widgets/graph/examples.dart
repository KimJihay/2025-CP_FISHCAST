import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';
import 'package:fishcast/core/widgets/graph/linechart_widget.dart';
import 'package:fishcast/core/widgets/graph/dual_linechart_widget.dart';

/// Example implementations showing how to use dynamic graph widgets
/// 
/// This file contains practical examples for developers to understand
/// how to connect their data to the graph widgets.

// ============================================================================
// EXAMPLE 1: Simple Price Chart with Custom Data
// ============================================================================

class SimplePriceChartExample extends StatelessWidget {
  const SimplePriceChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Your custom price data
    final List<double> fishPrices = [25, 28, 35, 45, 55, 70, 85, 80, 65, 50, 35, 28];
    
    // Convert to ChartDataPoint
    final chartData = createChartData(yValues: fishPrices);
    
    return SizedBox(
      height: 300,
      child: LinechartWidget(
        data: chartData,
        lineConfig: LineConfig(
          color: Colors.blue,
          label: 'Fish Price (₱)',
          lineWidth: 2.5,
        ),
        axisConfig: AxisConfig(
          customLabels: defaultMonthLabels,
          interval: 20,
          minY: 0,
          maxY: 100,
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Temperature Chart with Custom Colors
// ============================================================================

class TemperatureChartExample extends StatelessWidget {
  const TemperatureChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Weekly temperature data
    final weeklyTemps = [22.5, 23.0, 24.5, 25.0, 26.5, 27.0, 25.5];
    
    final tempData = createChartData(
      yValues: weeklyTemps,
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );
    
    return SizedBox(
      height: 250,
      child: LinechartWidget(
        data: tempData,
        lineConfig: LineConfig(
          color: Colors.orange,
          label: 'Temperature (°C)',
          lineWidth: 3.0,
          showDots: true,
          showArea: true,
          areaOpacity: 0.15,
        ),
        axisConfig: AxisConfig(
          customLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          interval: 5,
          minY: 15,
          maxY: 35,
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Comparison Chart (Actual vs Forecast)
// ============================================================================

class ComparisonChartExample extends StatelessWidget {
  const ComparisonChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Actual sales data
    final actualSales = [120.0, 150.0, 180.0, 160.0, 200.0, 220.0, 240.0, 230.0, 250.0, 270.0, 260.0, 280.0];
    
    // Forecast data
    final forecastSales = [130.0, 145.0, 175.0, 170.0, 195.0, 215.0, 235.0, 240.0, 255.0, 265.0, 270.0, 285.0];
    
    final actualData = createChartData(yValues: actualSales);
    final forecastData = createChartData(yValues: forecastSales);
    
    return SizedBox(
      height: 350,
      child: DualLinechartWidget(
        line1Data: actualData,
        line2Data: forecastData,
        line1Config: LineConfig(
          color: Colors.green,
          label: 'Actual',
          lineWidth: 2.5,
          showArea: true,
        ),
        line2Config: LineConfig(
          color: Colors.blue,
          label: 'Forecast',
          lineWidth: 2.5,
          showArea: true,
          isCurved: true,
        ),
        axisConfig: AxisConfig(
          customLabels: defaultMonthLabels,
          interval: 50,
          minY: 0,
          maxY: 300,
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Dynamic Data from Variables
// ============================================================================

class DynamicDataChartExample extends StatefulWidget {
  const DynamicDataChartExample({super.key});

  @override
  State<DynamicDataChartExample> createState() => _DynamicDataChartExampleState();
}

class _DynamicDataChartExampleState extends State<DynamicDataChartExample> {
  // Your data variables - can be updated from anywhere
  List<double> myDataValues = [10, 20, 15, 25, 30, 28, 35, 40, 38, 45, 42, 50];
  String selectedFish = 'Galunggong';
  Color chartColor = Colors.blue;
  
  // Method to update data (e.g., from API, user selection, etc.)
  void updateChartData(List<double> newData, String fishName, Color color) {
    setState(() {
      myDataValues = newData;
      selectedFish = fishName;
      chartColor = color;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Convert your data to chart format
    final chartData = createChartData(yValues: myDataValues);
    
    return Column(
      children: [
        // Example: Buttons to change data
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => updateChartData(
                [10, 20, 15, 25, 30, 28, 35, 40, 38, 45, 42, 50],
                'Galunggong',
                Colors.blue,
              ),
              child: Text('Galunggong'),
            ),
            ElevatedButton(
              onPressed: () => updateChartData(
                [15, 25, 20, 30, 35, 32, 40, 45, 42, 50, 48, 55],
                'Bangus',
                Colors.green,
              ),
              child: Text('Bangus'),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Chart updates automatically when data changes
        SizedBox(
          height: 300,
          child: LinechartWidget(
            data: chartData,
            lineConfig: LineConfig(
              color: chartColor,
              label: '$selectedFish Price',
              lineWidth: 2.5,
            ),
            axisConfig: AxisConfig(
              customLabels: defaultMonthLabels,
              interval: 10,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 5: Data from API/Database
// ============================================================================

class ApiDataChartExample extends StatefulWidget {
  const ApiDataChartExample({super.key});

  @override
  State<ApiDataChartExample> createState() => _ApiDataChartExampleState();
}

class _ApiDataChartExampleState extends State<ApiDataChartExample> {
  List<ChartDataPoint> chartData = [];
  bool isLoading = true;
  String errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    loadDataFromAPI();
  }
  
  // Simulate API call
  Future<void> loadDataFromAPI() async {
    try {
      setState(() => isLoading = true);
      
      // Simulate network delay
      await Future.delayed(Duration(seconds: 2));
      
      // Simulate API response
      // In real app, replace with: final response = await http.get(...)
      final apiData = [
        {'month': 0, 'value': 25.5},
        {'month': 1, 'value': 28.0},
        {'month': 2, 'value': 35.5},
        {'month': 3, 'value': 45.0},
        {'month': 4, 'value': 55.5},
        {'month': 5, 'value': 70.0},
      ];
      
      // Convert API data to ChartDataPoint
      final data = apiData.map((item) => ChartDataPoint(
        x: (item['month'] as num).toDouble(),
        y: (item['value'] as num).toDouble(),
      )).toList();
      
      setState(() {
        chartData = data;
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    
    return SizedBox(
      height: 300,
      child: LinechartWidget(
        data: chartData,
        lineConfig: LineConfig(
          color: Colors.purple,
          label: 'API Data',
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 6: Multiple Data Sources in One Chart
// ============================================================================

class MultiSourceChartExample extends StatelessWidget {
  const MultiSourceChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Data from different sources
    final databasePrices = [100.0, 105.0, 110.0, 108.0, 115.0, 120.0];
    final apiForecasts = [102.0, 107.0, 112.0, 115.0, 118.0, 125.0];
    
    // Convert to chart data
    final priceData = createChartData(yValues: databasePrices);
    final forecastData = createChartData(yValues: apiForecasts);
    
    return SizedBox(
      height: 300,
      child: DualLinechartWidget(
        line1Data: priceData,
        line2Data: forecastData,
        line1Config: LineConfig(
          color: Colors.indigo,
          label: 'Historical',
          showDots: true,
        ),
        line2Config: LineConfig(
          color: Colors.amber,
          label: 'Predicted',
          showDots: false,
          isCurved: false,
        ),
        axisConfig: AxisConfig(
          customLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
          interval: 20,
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 7: Custom Styling and Theming
// ============================================================================

class ThemedChartExample extends StatelessWidget {
  const ThemedChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary;
    
    final data1 = createChartData(yValues: [20.0, 25.0, 30.0, 28.0, 35.0, 40.0]);
    final data2 = createChartData(yValues: [18.0, 22.0, 28.0, 30.0, 32.0, 38.0]);
    
    return SizedBox(
      height: 300,
      child: DualLinechartWidget(
        line1Data: data1,
        line2Data: data2,
        line1Config: LineConfig(
          color: primaryColor,
          label: 'Primary',
          lineWidth: 3.0,
          areaOpacity: 0.2,
        ),
        line2Config: LineConfig(
          color: accentColor,
          label: 'Secondary',
          lineWidth: 3.0,
          areaOpacity: 0.2,
        ),
        axisConfig: AxisConfig(
          customLabels: ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6'],
          interval: 10,
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8: Connecting to a List Widget
// ============================================================================

class ListConnectedChartExample extends StatefulWidget {
  const ListConnectedChartExample({super.key});

  @override
  State<ListConnectedChartExample> createState() => _ListConnectedChartExampleState();
}

class _ListConnectedChartExampleState extends State<ListConnectedChartExample> {
  // Your data list (could come from anywhere)
  final List<Map<String, dynamic>> fishData = [
    {'name': 'Galunggong', 'prices': [25.0, 28.0, 30.0, 32.0, 35.0, 38.0, 40.0, 42.0, 45.0, 48.0, 50.0, 52.0]},
    {'name': 'Bangus', 'prices': [30.0, 32.0, 35.0, 38.0, 40.0, 42.0, 45.0, 48.0, 50.0, 52.0, 55.0, 58.0]},
    {'name': 'Bangus', 'prices': [40.0, 42.0, 45.0, 48.0, 50.0, 52.0, 55.0, 58.0, 60.0, 62.0, 65.0, 68.0]},
  ];
  
  int selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // Get selected fish data
    final selectedFish = fishData[selectedIndex];
    final chartData = createChartData(
      yValues: List<double>.from(selectedFish['prices']),
    );
    
    return Column(
      children: [
        // List of fish
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fishData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ChoiceChip(
                  label: Text(fishData[index]['name']),
                  selected: selectedIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedIndex = index);
                    }
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),
        // Chart updates based on list selection
        SizedBox(
          height: 300,
          child: LinechartWidget(
            data: chartData,
            lineConfig: LineConfig(
              color: Colors.teal,
              label: '${selectedFish['name']} Price',
              lineWidth: 2.5,
            ),
            axisConfig: AxisConfig(
              customLabels: defaultMonthLabels,
              interval: 10,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HELPER: How to use these examples
// ============================================================================

/// To use any of these examples in your app:
/// 
/// 1. Import this file:
///    import 'package:fishcast/core/widgets/graph/examples.dart';
/// 
/// 2. Use the example widget:
///    SimplePriceChartExample()
///    TemperatureChartExample()
///    DynamicDataChartExample()
///    etc.
/// 
/// 3. Customize the data and styling to match your needs
/// 
/// 4. Connect to your own data sources (API, database, state management, etc.)
