import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';

class DualLinechartWidget extends StatelessWidget {
  /// First line data points
  final List<ChartDataPoint> line1Data;
  
  /// Second line data points
  final List<ChartDataPoint> line2Data;
  
  /// Configuration for the first line
  final LineConfig line1Config;
  
  /// Configuration for the second line
  final LineConfig line2Config;
  
  /// Configuration for the chart axes
  final AxisConfig axisConfig;

  const DualLinechartWidget({
    super.key,
    required this.line1Data,
    required this.line2Data,
    this.line1Config = defaultPriceLineConfig,
    this.line2Config = defaultSupplyLineConfig,
    this.axisConfig = const AxisConfig(),
  });
  
  // Legacy constructor for backward compatibility
  const DualLinechartWidget.legacy({
    super.key,
    required List<PricePoint> pricePoints,
    required List<PricePoint> supplyPoints,
  }) : line1Data = pricePoints,
       line2Data = supplyPoints,
       line1Config = defaultPriceLineConfig,
       line2Config = defaultSupplyLineConfig,
       axisConfig = const AxisConfig();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              flex: 4, // 4 parts for chart
              child: SizedBox(
                width: double.infinity,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: axisConfig.showGrid,
                      drawVerticalLine: false,
                      horizontalInterval: axisConfig.interval ?? 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: axisConfig.showBottomTitles,
                          reservedSize: constraints.maxWidth < 300
                              ? 20
                              : 30, // Responsive size
                          getTitlesWidget: (value, meta) {
                            // Use custom labels if provided, otherwise use default months
                            final labels = axisConfig.customLabels ?? defaultMonthLabels;
                            if (value >= 0 && value < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: axisConfig.showLeftTitles,
                          reservedSize: constraints.maxWidth < 300
                              ? 30
                              : 40, // Responsive size
                          interval: axisConfig.interval ?? 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      // First line
                      LineChartBarData(
                        spots: line1Data
                            .map((point) => FlSpot(point.x, point.y))
                            .toList(),
                        isCurved: line1Config.isCurved,
                        color: line1Config.color,
                        barWidth: line1Config.lineWidth,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: line1Config.showDots),
                        belowBarData: BarAreaData(
                          show: line1Config.showArea,
                          color: line1Config.color.withValues(alpha: line1Config.areaOpacity),
                        ),
                      ),
                      // Second line
                      LineChartBarData(
                        spots: line2Data
                            .map((point) => FlSpot(point.x, point.y))
                            .toList(),
                        isCurved: line2Config.isCurved,
                        color: line2Config.color,
                        barWidth: line2Config.lineWidth,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: line2Config.showDots),
                        belowBarData: BarAreaData(
                          show: line2Config.showArea,
                          color: line2Config.color.withValues(alpha: line2Config.areaOpacity),
                        ),
                      ),
                    ],
                    minX: axisConfig.minX ?? 0,
                    maxX: axisConfig.maxX ?? 11, // For 12 months (0-11)
                    minY: axisConfig.minY ?? 0,
                    maxY: axisConfig.maxY,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Responsive Legend
            Expanded(
              flex: 1, // 1 part for legend
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: constraints.maxWidth < 300 ? 10 : 12,
                          height: 2,
                          color: line1Config.color,
                        ),
                        SizedBox(width: constraints.maxWidth < 300 ? 2 : 4),
                        FittedBox(
                          child: Text(
                            line1Config.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: line1Config.color,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: constraints.maxWidth < 300 ? 10 : 20),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: constraints.maxWidth < 300 ? 10 : 12,
                          height: 2,
                          color: line2Config.color,
                        ),
                        SizedBox(width: constraints.maxWidth < 300 ? 2 : 4),
                        FittedBox(
                          child: Text(
                            line2Config.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: line2Config.color,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
