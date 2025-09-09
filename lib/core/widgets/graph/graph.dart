class PricePoint {
  final double x;
  final double y;
  PricePoint({required this.x, required this.y});
}

List<PricePoint> get pricePoints {
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
            MapEntry(index, PricePoint(x: index.toDouble(), y: value)),
      )
      .values
      .toList();
}
