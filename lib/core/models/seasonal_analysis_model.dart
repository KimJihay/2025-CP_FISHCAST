class SeasonalAnalysis {
  final OverallSeasonalData overall;
  final Map<String, FishSeasonalData> byFish;
  final String updatedAt;

  SeasonalAnalysis({
    required this.overall,
    required this.byFish,
    required this.updatedAt,
  });

  factory SeasonalAnalysis.fromJson(Map<String, dynamic> json) {
    Map<String, FishSeasonalData> fishMap = {};
    
    if (json['by_fish'] != null) {
      json['by_fish'].forEach((key, value) {
        fishMap[key] = FishSeasonalData.fromJson(value);
      });
    }

    return SeasonalAnalysis(
      overall: OverallSeasonalData.fromJson(json['overall'] ?? {}),
      byFish: fishMap,
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class OverallSeasonalData {
  final List<MonthlyData> monthlyData;
  final String peakPriceMonth;
  final double peakPriceValue;
  final String lowPriceMonth;
  final double lowPriceValue;
  final String peakSupplyMonth;
  final double peakSupplyValue;
  final String lowSupplyMonth;
  final double lowSupplyValue;

  OverallSeasonalData({
    required this.monthlyData,
    required this.peakPriceMonth,
    required this.peakPriceValue,
    required this.lowPriceMonth,
    required this.lowPriceValue,
    required this.peakSupplyMonth,
    required this.peakSupplyValue,
    required this.lowSupplyMonth,
    required this.lowSupplyValue,
  });

  factory OverallSeasonalData.fromJson(Map<String, dynamic> json) {
    List<MonthlyData> monthly = [];
    if (json['monthly_data'] != null) {
      monthly = (json['monthly_data'] as List)
          .map((item) => MonthlyData.fromJson(item))
          .toList();
    }

    return OverallSeasonalData(
      monthlyData: monthly,
      peakPriceMonth: json['peak_price_month'] ?? '',
      peakPriceValue: (json['peak_price_value'] ?? 0).toDouble(),
      lowPriceMonth: json['low_price_month'] ?? '',
      lowPriceValue: (json['low_price_value'] ?? 0).toDouble(),
      peakSupplyMonth: json['peak_supply_month'] ?? '',
      peakSupplyValue: (json['peak_supply_value'] ?? 0).toDouble(),
      lowSupplyMonth: json['low_supply_month'] ?? '',
      lowSupplyValue: (json['low_supply_value'] ?? 0).toDouble(),
    );
  }
}

class FishSeasonalData {
  final String fishName;
  final String fishKey;
  final List<MonthlyData> monthlyData;
  final String peakPriceMonth;
  final double peakPriceValue;
  final String lowPriceMonth;
  final double lowPriceValue;
  final String peakSupplyMonth;
  final double peakSupplyValue;
  final String lowSupplyMonth;
  final double lowSupplyValue;
  final double priceVolatility;
  final double supplyVolatility;

  FishSeasonalData({
    required this.fishName,
    required this.fishKey,
    required this.monthlyData,
    required this.peakPriceMonth,
    required this.peakPriceValue,
    required this.lowPriceMonth,
    required this.lowPriceValue,
    required this.peakSupplyMonth,
    required this.peakSupplyValue,
    required this.lowSupplyMonth,
    required this.lowSupplyValue,
    required this.priceVolatility,
    required this.supplyVolatility,
  });

  factory FishSeasonalData.fromJson(Map<String, dynamic> json) {
    List<MonthlyData> monthly = [];
    if (json['monthly_data'] != null) {
      monthly = (json['monthly_data'] as List)
          .map((item) => MonthlyData.fromJson(item))
          .toList();
    }

    return FishSeasonalData(
      fishName: json['fish_name'] ?? '',
      fishKey: json['fish_key'] ?? '',
      monthlyData: monthly,
      peakPriceMonth: json['peak_price_month'] ?? '',
      peakPriceValue: (json['peak_price_value'] ?? 0).toDouble(),
      lowPriceMonth: json['low_price_month'] ?? '',
      lowPriceValue: (json['low_price_value'] ?? 0).toDouble(),
      peakSupplyMonth: json['peak_supply_month'] ?? '',
      peakSupplyValue: (json['peak_supply_value'] ?? 0).toDouble(),
      lowSupplyMonth: json['low_supply_month'] ?? '',
      lowSupplyValue: (json['low_supply_value'] ?? 0).toDouble(),
      priceVolatility: (json['price_volatility'] ?? 0).toDouble(),
      supplyVolatility: (json['supply_volatility'] ?? 0).toDouble(),
    );
  }
}

class MonthlyData {
  final int monthNumber;
  final String monthName;
  final double avgPrice;
  final double? minPrice;
  final double? maxPrice;
  final double? priceStd;
  final double avgSupply;
  final double? minSupply;
  final double? maxSupply;
  final double? supplyStd;
  final double? totalSupply;

  MonthlyData({
    required this.monthNumber,
    required this.monthName,
    required this.avgPrice,
    this.minPrice,
    this.maxPrice,
    this.priceStd,
    required this.avgSupply,
    this.minSupply,
    this.maxSupply,
    this.supplyStd,
    this.totalSupply,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      monthNumber: json['month_number'] ?? 0,
      monthName: json['month_name'] ?? '',
      avgPrice: (json['avg_price'] ?? 0).toDouble(),
      minPrice: json['min_price'] != null ? (json['min_price'] as num).toDouble() : null,
      maxPrice: json['max_price'] != null ? (json['max_price'] as num).toDouble() : null,
      priceStd: json['price_std'] != null ? (json['price_std'] as num).toDouble() : null,
      avgSupply: (json['avg_supply'] ?? 0).toDouble(),
      minSupply: json['min_supply'] != null ? (json['min_supply'] as num).toDouble() : null,
      maxSupply: json['max_supply'] != null ? (json['max_supply'] as num).toDouble() : null,
      supplyStd: json['supply_std'] != null ? (json['supply_std'] as num).toDouble() : null,
      totalSupply: json['total_supply'] != null ? (json['total_supply'] as num).toDouble() : null,
    );
  }
}
