
enum DemandTrend { increasing, decreasing, stable }

class BrandForecast {
  final String brand;
  final String historicalSales; 
  final String projectedSales; 
  final double projectedGrowthPercent; 
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
