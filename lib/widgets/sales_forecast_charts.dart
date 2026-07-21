import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/sales_forecast.dart';
import '../services/chart_data.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';

// ============================================================================
// CHART 1 — Sales Trend (Actual vs a simple 3-month-average projection)
// ============================================================================
class SalesTrendChart extends StatelessWidget {
  final List<double> actualTotals;
  final List<String> monthLabels;
  final double projectedFlatValue;

  const SalesTrendChart({
    super.key,
    required this.actualTotals,
    required this.monthLabels,
    required this.projectedFlatValue,
  });

  @override
  Widget build(BuildContext context) {
    final double maxActual = actualTotals.isEmpty
        ? 0
        : actualTotals.reduce((a, b) => a > b ? a : b);
    final double maxValue = maxActual > projectedFlatValue ? maxActual : projectedFlatValue;
    final double maxY = maxValue <= 0 ? 10 : (maxValue * 1.25);
    final double interval = maxY / 5;

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trend (Actual vs Projected)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _LegendItem(color: AppColors.chartBlueMed, label: 'Actual'),
              _LegendItem(color: AppColors.chartGray, label: 'Projected (3-mo avg)'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: actualTotals.every((v) => v == 0)
                ? const Center(
                    child: Text(
                      'No sales logged yet',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (v) => const FlLine(
                          color: AppColors.borderLight,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= monthLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  monthLabels[i],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < actualTotals.length; i++)
                              FlSpot(i.toDouble(), projectedFlatValue),
                          ],
                          isCurved: false,
                          dashArray: [6, 4],
                          color: AppColors.chartGray,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                        _buildLine(actualTotals, AppColors.chartBlueMed),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<double> series, Color color) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i]),
      ],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) =>
            FlDotCirclePainter(radius: 4, color: color, strokeWidth: 0),
      ),
      belowBarData: BarAreaData(show: false),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CHART 2 — Historical vs Projected Sales by Brand
// ============================================================================
class ForecastedDemandChart extends StatelessWidget {
  final List<BrandForecast> forecasts;

  const ForecastedDemandChart({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    final historicalValues = [
      for (final f in forecasts) parseAmountString(f.historicalSales),
    ];
    final projectedValues = [
      for (final f in forecasts) parseAmountString(f.projectedSales),
    ];
    final double maxValue = [...historicalValues, ...projectedValues].isEmpty
        ? 0
        : [...historicalValues, ...projectedValues].reduce((a, b) => a > b ? a : b);
    final double maxY = maxValue <= 0 ? 10 : (maxValue * 1.2);
    final double interval = maxY / 4;

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historical vs Projected Sales by Brand',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendItem(color: AppColors.chartBlueLight, label: 'Historical (6mo)'),
              _LegendItem(color: AppColors.chartBlueDark, label: 'Projected (3mo)'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: forecasts.isEmpty
                ? const Center(
                    child: Text(
                      'No forecasts added yet',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (v) => const FlLine(
                          color: AppColors.borderLight,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= forecasts.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  forecasts[i].brand,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (int i = 0; i < forecasts.length; i++)
                          _buildGroup(i, historicalValues[i], projectedValues[i]),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildGroup(int index, double historical, double projected) {
    return BarChartGroupData(
      x: index,
      barsSpace: 4,
      barRods: [
        BarChartRodData(
          toY: historical,
          width: 12,
          color: AppColors.chartBlueLight,
          borderRadius: BorderRadius.circular(2),
        ),
        BarChartRodData(
          toY: projected,
          width: 12,
          color: AppColors.chartBlueDark,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}
