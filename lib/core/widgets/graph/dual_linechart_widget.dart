import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fishcast/core/widgets/graph/graph.dart';

class DualLinechartWidget extends StatelessWidget {
  final List<PricePoint> pricePoints;
  final List<PricePoint> supplyPoints;

  const DualLinechartWidget({
    super.key,
    required this.pricePoints,
    required this.supplyPoints,
  });

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
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
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
                          showTitles: true,
                          reservedSize: constraints.maxWidth < 300
                              ? 20
                              : 30, // Responsive size
                          getTitlesWidget: (value, meta) {
                            // Map x values to month names (0-11 for Jan-Dec)
                            const months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            if (value >= 0 && value < months.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  months[value.toInt()],
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
                          showTitles: true,
                          reservedSize: constraints.maxWidth < 300
                              ? 30
                              : 40, // Responsive size
                          interval: 20,
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
                      // Price line (blue)
                      LineChartBarData(
                        spots: pricePoints
                            .map((point) => FlSpot(point.x, point.y))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.1),
                        ),
                      ),
                      // Supply line (green)
                      LineChartBarData(
                        spots: supplyPoints
                            .map((point) => FlSpot(point.x, point.y))
                            .toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    minX: 0,
                    maxX: 11, // For 12 months (0-11)
                    minY: 0,
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
                          color: Colors.blue,
                        ),
                        SizedBox(width: constraints.maxWidth < 300 ? 2 : 4),
                        FittedBox(
                          child: Text(
                            'Price',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
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
                          color: Colors.green,
                        ),
                        SizedBox(width: constraints.maxWidth < 300 ? 2 : 4),
                        FittedBox(
                          child: Text(
                            'Supply',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
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
