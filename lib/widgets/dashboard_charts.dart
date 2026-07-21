import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common_widgets.dart';

// ============================================================================
// CHART 1 — Sales Overview (monthly revenue trend, last 6 months)
// ============================================================================
class SalesOverviewChart extends StatelessWidget {
  final List<double> monthlyTotals;
  final List<String> monthLabels;

  const SalesOverviewChart({
    super.key,
    required this.monthlyTotals,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = monthlyTotals.isEmpty
        ? 0
        : monthlyTotals.reduce((a, b) => a > b ? a : b);
    final double maxY = maxValue <= 0 ? 10 : (maxValue * 1.2);
    final double interval = maxY / 5;

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sales Overview',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              PeriodChip(label: '6 Months'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: monthlyTotals.every((v) => v == 0)
                ? const _EmptyChartMessage(message: 'No sales logged yet')
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
                      lineBarsData: [_buildLine(monthlyTotals, AppColors.chartBlueMed)],
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
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
    );
  }
}

// ============================================================================
// CHART 2 — Monthly Sales Revenue (bar chart, last 6 months)
// ============================================================================
class MonthlyRevenueChart extends StatelessWidget {
  final List<double> monthlyTotals;
  final List<String> monthLabels;

  const MonthlyRevenueChart({
    super.key,
    required this.monthlyTotals,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = monthlyTotals.isEmpty
        ? 0
        : monthlyTotals.reduce((a, b) => a > b ? a : b);
    final double maxY = maxValue <= 0 ? 10 : (maxValue * 1.2);
    final double interval = maxY / 5;

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Sales Revenue',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: monthlyTotals.every((v) => v == 0)
                ? const _EmptyChartMessage(message: 'No sales logged yet')
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
                              if (i < 0 || i >= monthLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  monthLabels[i],
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
                        for (int i = 0; i < monthlyTotals.length; i++)
                          _buildGroup(i, monthlyTotals[i]),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildGroup(int index, double value) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 20,
          borderRadius: BorderRadius.circular(3),
          color: AppColors.chartBlueDark,
        ),
      ],
    );
  }
}

// ============================================================================
// CHART 3 — Inventory Performance (donut chart, live status breakdown)
// ============================================================================
class InventoryPerformanceChart extends StatelessWidget {
  final Map<String, int> statusCounts;

  const InventoryPerformanceChart({super.key, required this.statusCounts});

  static const List<Color> _colors = [
    AppColors.chartBlueDark,
    AppColors.chartBlueMed,
    AppColors.chartBlueLight,
    AppColors.chartGray,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = statusCounts.entries.where((e) => e.value > 0).toList();
    final int total = entries.fold(0, (sum, e) => sum + e.value);

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Inventory Performance',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < entries.length; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    _LegendDot(
                      label: entries[i].key,
                      color: _colors[i % _colors.length],
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (total == 0)
            const SizedBox(
              height: 190,
              child: _EmptyChartMessage(message: 'No inventory yet'),
            )
          else ...[
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 52,
                  sections: [
                    for (int i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value.toDouble(),
                        color: _colors[i % _colors.length],
                        radius: 38,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final e in entries)
                  Text(
                    '${(e.value / total * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ============================================================================
// CHART 4 — Actual vs 6-Month Average (filled area/line chart)
// ============================================================================
class ActualVsPredictedChart extends StatelessWidget {
  final List<double> monthlyTotals;
  final List<String> monthLabels;

  const ActualVsPredictedChart({
    super.key,
    required this.monthlyTotals,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final double average = monthlyTotals.isEmpty
        ? 0
        : monthlyTotals.reduce((a, b) => a + b) / monthlyTotals.length;
    final double maxValue = monthlyTotals.isEmpty
        ? 0
        : monthlyTotals.reduce((a, b) => a > b ? a : b);
    final double maxY = (maxValue <= 0 && average <= 0) ? 10 : (maxValue * 1.2).clamp(average * 1.2, double.infinity);
    final double interval = maxY / 5;

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Actual vs 6-Month Average',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              PeriodChip(label: '6 Months'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: monthlyTotals.every((v) => v == 0)
                ? const _EmptyChartMessage(message: 'No sales logged yet')
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
                            for (int i = 0; i < monthlyTotals.length; i++)
                              FlSpot(i.toDouble(), average),
                          ],
                          isCurved: false,
                          color: AppColors.chartGray,
                          barWidth: 2,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < monthlyTotals.length; i++)
                              FlSpot(i.toDouble(), monthlyTotals[i]),
                          ],
                          isCurved: true,
                          color: AppColors.chartBlueMed,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.chartBlueMed.withValues(alpha: 0.25),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  final String message;
  const _EmptyChartMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
    );
  }
}

// ============================================================================
// KEY INSIGHTS 
// ============================================================================
class KeyInsightsCard extends StatelessWidget {
  final List<String> insights;

  const KeyInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textDark.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'Key Insights',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (insights.isEmpty)
            const Text(
              'Not enough data yet to generate insights.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else
            for (final insight in insights)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
