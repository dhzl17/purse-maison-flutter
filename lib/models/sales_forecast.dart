/// Direction of a brand's projected demand.
enum DemandTrend { increasing, decreasing, stable }

/// A row in the brand forecast table.
///
/// Backed by Firestore collection `salesForecasts/{brand}`.
class BrandForecast {
  final String brand;
  final String historicalSales; // formatted, e.g. "4,850,000"
  final String projectedSales; // formatted, e.g. "5,420,000"
  final double projectedGrowthPercent; // signed, e.g. 11.8 or -15.6
  final DemandTrend trend;

  const BrandForecast({
    required this.brand,
    required this.historicalSales,
    required this.projectedSales,
    required this.projectedGrowthPercent,
    required this.trend,
  });

  factory BrandForecast.fromMap(String id, Map<String, dynamic> map) {
    return BrandForecast(
      brand: map['brand'] as String? ?? id,
      historicalSales: map['historicalSales'] as String? ?? '0',
      projectedSales: map['projectedSales'] as String? ?? '0',
      projectedGrowthPercent:
          (map['projectedGrowthPercent'] as num?)?.toDouble() ?? 0,
      trend: DemandTrend.values.byName(map['trend'] as String? ?? 'stable'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'historicalSales': historicalSales,
      'projectedSales': projectedSales,
      'projectedGrowthPercent': projectedGrowthPercent,
      'trend': trend.name,
    };
  }
}
