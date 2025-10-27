/// Model representing a fish price forecast
class FishForecast {
  final String fishType;
  final List<ForecastDataPoint> forecast;
  final String? modelOrder;
  final DateTime? updatedAt;

  FishForecast({
    required this.fishType,
    required this.forecast,
    this.modelOrder,
    this.updatedAt,
  });

  /// Create FishForecast from JSON (API response)
  factory FishForecast.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['forecast'] as List<dynamic>)
        .map((item) => ForecastDataPoint.fromJson(item as Map<String, dynamic>))
        .toList();

    return FishForecast(
      fishType: json['fish_type'] ?? '',
      forecast: forecastList,
      modelOrder: json['model_order'],
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fish_type': fishType,
      'forecast': forecast.map((point) => point.toJson()).toList(),
      'model_order': modelOrder,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Model representing a single forecast data point (date + price)
class ForecastDataPoint {
  final DateTime date;
  final double price;

  ForecastDataPoint({
    required this.date,
    required this.price,
  });

  /// Create ForecastDataPoint from JSON
  factory ForecastDataPoint.fromJson(Map<String, dynamic> json) {
    return ForecastDataPoint(
      date: DateTime.parse(json['date']),
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'price': price,
    };
  }

  @override
  String toString() => 'ForecastDataPoint(date: ${date.toIso8601String().split('T')[0]}, price: ₱$price)';
}
