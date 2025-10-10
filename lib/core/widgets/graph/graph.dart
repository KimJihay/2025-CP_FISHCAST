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

List<PricePoint> get supplyPoints {
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
            MapEntry(index, PricePoint(x: index.toDouble(), y: value)),
      )
      .values
      .toList();
}
