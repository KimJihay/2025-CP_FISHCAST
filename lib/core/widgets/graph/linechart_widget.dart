import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';

class LinechartWidget extends StatelessWidget {
  /// Data points to display on the chart
  final List<ChartDataPoint> data;
  
  /// Configuration for the line appearance
  final LineConfig lineConfig;
  
  /// Configuration for the chart axes
  final AxisConfig axisConfig;
  
  const LinechartWidget({
    super.key,
    required this.data,
    this.lineConfig = defaultPriceLineConfig,
    this.axisConfig = const AxisConfig(),
  });
  
  // Legacy constructor for backward compatibility
  const LinechartWidget.legacy({
    super.key,
    required List<PricePoint> pricePoints,
  }) : data = pricePoints,
       lineConfig = defaultPriceLineConfig,
       axisConfig = const AxisConfig();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontSize = screenWidth < 360 ? 9.0 : 10.0;
        final bottomReservedSize = screenWidth < 300 ? 20.0 : 30.0;
        final leftReservedSize = screenWidth < 300 ? 30.0 : 40.0;

        return LineChart(
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
                  reservedSize: bottomReservedSize,
                  getTitlesWidget: (value, meta) {
                    // Use custom labels if provided, otherwise use default months
                    final labels = axisConfig.customLabels ?? defaultMonthLabels;
                    if (value >= 0 && value < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[value.toInt()],
                          style: TextStyle(
                            fontSize: fontSize,
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
                  reservedSize: leftReservedSize,
                  interval: axisConfig.interval ?? 20,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(color: Colors.grey, fontSize: fontSize),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: data
                    .map((point) => FlSpot(point.x, point.y))
                    .toList(),
                isCurved: lineConfig.isCurved,
                color: lineConfig.color,
                barWidth: lineConfig.lineWidth,
                isStrokeCapRound: true,
                dotData: FlDotData(show: lineConfig.showDots),
                belowBarData: BarAreaData(
                  show: lineConfig.showArea,
                  color: lineConfig.color.withValues(alpha: lineConfig.areaOpacity),
                ),
              ),
            ],
            minX: axisConfig.minX ?? 0,
            maxX: axisConfig.maxX ?? 11, // For 12 months (0-11)
            minY: axisConfig.minY ?? 0,
            maxY: axisConfig.maxY,
          ),
        );
      },
    );
  }
}
