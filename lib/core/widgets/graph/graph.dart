import 'package:flutter/material.dart';

/// Generic data point for charts
class ChartDataPoint {
  final double x;
  final double y;
  final String? label; // Optional label for the data point
  
  ChartDataPoint({
    required this.x,
    required this.y,
    this.label,
  });
}

/// Configuration for a single line in a chart
class LineConfig {
  final Color color;
  final String label;
  final double lineWidth;
  final bool showDots;
  final bool showArea;
  final bool isCurved;
  final double areaOpacity;
  
  const LineConfig({
    required this.color,
    required this.label,
    this.lineWidth = 2.0,
    this.showDots = true,
    this.showArea = true,
    this.isCurved = true,
    this.areaOpacity = 0.1,
  });
}

/// Configuration for chart axes
class AxisConfig {
  final List<String>? customLabels; // Custom labels for x-axis
  final double? interval; // Interval for y-axis
  final double? minY;
  final double? maxY;
  final double? minX;
  final double? maxX;
  final bool showLeftTitles;
  final bool showBottomTitles;
  final bool showGrid;
  
  const AxisConfig({
    this.customLabels,
    this.interval,
    this.minY,
    this.maxY,
    this.minX,
    this.maxX,
    this.showLeftTitles = true,
    this.showBottomTitles = true,
    this.showGrid = true,
  });
}

// Legacy alias for backward compatibility
typedef PricePoint = ChartDataPoint;

/// Sample data generator for price points (12 months)
List<ChartDataPoint> get pricePoints {
  // Sample data for 12 months (Jan-Dec)
  final monthlyData = <double>[
    25, // Jan
    28, // Feb
    35, // Mar
    45, // Apr
    55, // May
    70, // Jun
    85, // Jul
    80, // Aug
    65, // Sep
    50, // Oct
    35, // Nov
    28, // Dec
  ];

  return monthlyData
      .asMap()
      .map(
        (index, value) =>
            MapEntry(index, ChartDataPoint(x: index.toDouble(), y: value)),
      )
      .values
      .toList();
}

/// Helper function to create chart data from lists
List<ChartDataPoint> createChartData({
  required List<double> yValues,
  List<double>? xValues,
  List<String>? labels,
}) {
  return List.generate(yValues.length, (index) {
    return ChartDataPoint(
      x: xValues?[index] ?? index.toDouble(),
      y: yValues[index],
      label: labels?[index],
    );
  });
}

/// Sample data generator for supply points (12 months)
List<ChartDataPoint> get supplyPoints {
  // Sample supply data for 12 months (Jan-Dec)
  final monthlySupplyData = <double>[
    100, // Jan
    95,  // Feb
    110, // Mar
    125, // Apr
    140, // May
    160, // Jun
    180, // Jul
    175, // Aug
    155, // Sep
    130, // Oct
    115, // Nov
    105, // Dec
  ];

  return monthlySupplyData
      .asMap()
      .map(
        (index, value) =>
            MapEntry(index, ChartDataPoint(x: index.toDouble(), y: value)),
      )
      .values
      .toList();
}

/// Default month labels for charts
const List<String> defaultMonthLabels = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Default line configurations
const LineConfig defaultPriceLineConfig = LineConfig(
  color: Colors.blue,
  label: 'Price',
);

const LineConfig defaultSupplyLineConfig = LineConfig(
  color: Colors.green,
  label: 'Supply',
);
