import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common_widgets.dart';

// ============================================================================
// PANEL 1 — Inventory by Location (horizontal bar chart, live counts)
//
// fl_chart's BarChart only draws vertical bars, so this is hand-built from
// plain Containers rather than forced into fl_chart's API.
// ============================================================================
class InventoryByLocationChart extends StatelessWidget {
  /// Item count per location, in whatever order the caller wants shown —
  /// built from whatever distinct `location` values actually exist in
  /// inventory right now, not a fixed hardcoded list.
  final List<MapEntry<String, int>> counts;

  const InventoryByLocationChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final int maxValue = counts.isEmpty
        ? 0
        : counts.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    // Round up to a clean axis ceiling above the tallest bar.
    final double axisMax = maxValue <= 0 ? 10 : (maxValue * 1.25);
    final List<int> axisTicks = [
      0,
      (axisMax / 3).round(),
      (axisMax * 2 / 3).round(),
      axisMax.round(),
    ];

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory by Location',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 24),
          if (counts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No inventory yet',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            )
          else ...[
            for (final entry in counts) ...[
              _BarRow(label: entry.key, value: entry.value.toDouble(), maxValue: axisMax),
              const SizedBox(height: 18),
            ],
            Row(
              children: [
                const SizedBox(width: 86),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final tick in axisTicks)
                        Text(
                          '$tick',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;

  const _BarRow({required this.label, required this.value, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textDark)),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: maxValue <= 0 ? 0 : (value / maxValue).clamp(0.0, 1.0).toDouble(),
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.chartBlueDark,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PANEL 2 — Inventory Turnover Rate (line chart, last 6 months)
//
// Same simplified turnover proxy as the Dashboard's KPI card: share of
// current inventory sold that month. A textbook turnover rate needs
// cost-of-goods-sold and average inventory value over time, which this
// schema doesn't track — this is "how much of what's on the shelf moved
// each month" instead.
// ============================================================================
class InventoryTurnoverLineChart extends StatelessWidget {
  final List<double> turnoverPercentByMonth;
  final List<String> monthLabels;

  const InventoryTurnoverLineChart({
    super.key,
    required this.turnoverPercentByMonth,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = turnoverPercentByMonth.isEmpty
        ? 0
        : turnoverPercentByMonth.reduce((a, b) => a > b ? a : b);
    final double maxY = maxValue <= 0 ? 10 : (maxValue * 1.3);
    final double interval = maxY / 5;

    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Turnover Rate',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: turnoverPercentByMonth.every((v) => v == 0)
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
                        getDrawingHorizontalLine: (v) =>
                            const FlLine(color: AppColors.borderLight, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 38,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < turnoverPercentByMonth.length; i++)
                              FlSpot(i.toDouble(), turnoverPercentByMonth[i]),
                          ],
                          isCurved: true,
                          color: AppColors.chartBlueDark,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.chartBlueDark,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(show: false),
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

// ============================================================================
// PANEL 3 — Slowest-Moving Items (leaderboard list with a "View" action)
//
// Items that took the longest to sell, computed from real sales history
// (see TurnoverEntry below) — was a hardcoded top-4 list before.
// ============================================================================
class TurnoverLeaderboardCard extends StatelessWidget {
  final List<TurnoverEntry> entries;

  const TurnoverLeaderboardCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Slowest-Moving Items',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No sales history yet — this fills in once items start selling.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            )
          else
            for (int i = 0; i < entries.length; i++) ...[
              _TurnoverRow(entry: entries[i]),
              if (i != entries.length - 1)
                const Divider(height: 20, color: AppColors.borderLight),
            ],
        ],
      ),
    );
  }
}

/// One row of sales history: how long an item sat before it sold.
class TurnoverEntry {
  final String name;
  final int days;
  final String price;
  const TurnoverEntry({required this.name, required this.days, required this.price});
}

class _TurnoverRow extends StatelessWidget {
  final TurnoverEntry entry;
  const _TurnoverRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${entry.days} Days   ${entry.price}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
