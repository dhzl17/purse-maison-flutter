import 'package:flutter/material.dart';

import '../models/client_assignment.dart';
import '../models/consignment_item.dart';
import '../models/inventory_item.dart';
import '../models/sales_transaction.dart';
import '../services/app_repositories.dart';
import '../services/app_session.dart';
import '../services/chart_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dashboard_charts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      selectedIndex: 0,
      body: _DashboardBody(),
    );
  }
}

class _DashboardStats {
  final int itemsSold;
  final int activeConsignedItems;
  final double thisMonthTotal;
  final double growthPercent;
  final double? avgDisplayDurationDays;
  final double turnoverRate;
  final int totalInquiries;
  final int fastMovingCount;
  final int slowMovingCount;
  final List<String> monthLabels;
  final List<double> monthlyTotals;
  final Map<String, int> statusCounts;

  const _DashboardStats({
    required this.itemsSold,
    required this.activeConsignedItems,
    required this.thisMonthTotal,
    required this.growthPercent,
    required this.avgDisplayDurationDays,
    required this.turnoverRate,
    required this.totalInquiries,
    required this.fastMovingCount,
    required this.slowMovingCount,
    required this.monthLabels,
    required this.monthlyTotals,
    required this.statusCounts,
  });
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  static DateTime? _parseDateAdded(String s) {
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final m = int.tryParse(parts[0]);
    final d = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (m == null || d == null || y == null) return null;
    return DateTime(y, m, d);
  }

  _DashboardStats _computeStats(
    List<InventoryItem> inventory,
    List<ConsignmentItem> consignments,
    List<SalesTransaction> transactions,
    List<ClientInquiry> inquiries,
  ) {
    final int itemsSold =
        inventory.where((i) => i.status == InventoryStatus.sold).length;
    final int activeConsignedItems = consignments
        .where((c) => c.payoutStatus != PayoutStatus.cancelled)
        .length;

    final now = DateTime.now();
    final lastMonthDate = DateTime(now.year, now.month - 1);
    double thisMonthTotal = 0;
    double lastMonthTotal = 0;
    for (final t in transactions) {
      if (t.date.year == now.year && t.date.month == now.month) {
        thisMonthTotal += t.amount;
      } else if (t.date.year == lastMonthDate.year &&
          t.date.month == lastMonthDate.month) {
        lastMonthTotal += t.amount;
      }
    }
    final double growthPercent = lastMonthTotal == 0
        ? 0
        : ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;

    final inventoryById = {for (final item in inventory) item.itemId: item};
    final List<int> displayDurations = [];
    for (final t in transactions) {
      if (t.itemId == null) continue;
      final item = inventoryById[t.itemId];
      if (item == null) continue;
      final addedDate = _parseDateAdded(item.dateAdded);
      if (addedDate == null) continue;
      final days = t.date.difference(addedDate).inDays;
      if (days >= 0) displayDurations.add(days);
    }
    final double? avgDisplayDuration = displayDurations.isEmpty
        ? null
        : displayDurations.reduce((a, b) => a + b) / displayDurations.length;
    final int fastMovingCount = displayDurations.where((d) => d <= 30).length;
    final int slowMovingCount = displayDurations.where((d) => d > 60).length;

    final double turnoverRate =
        inventory.isEmpty ? 0 : itemsSold / inventory.length;

    final months = lastNMonths(6);
    final monthLabels = [for (final m in months) m.label];
    final monthlyTotals = monthlySalesTotals(transactions, months);

    final statusCounts = <String, int>{
      'Available':
          inventory.where((i) => i.status == InventoryStatus.available).length,
      'Reserved':
          inventory.where((i) => i.status == InventoryStatus.reserved).length,
      'Rejected':
          inventory.where((i) => i.status == InventoryStatus.rejected).length,
      'Sold': itemsSold,
    };

    return _DashboardStats(
      itemsSold: itemsSold,
      activeConsignedItems: activeConsignedItems,
      thisMonthTotal: thisMonthTotal,
      growthPercent: growthPercent,
      avgDisplayDurationDays: avgDisplayDuration,
      turnoverRate: turnoverRate,
      totalInquiries: inquiries.length,
      fastMovingCount: fastMovingCount,
      slowMovingCount: slowMovingCount,
      monthLabels: monthLabels,
      monthlyTotals: monthlyTotals,
      statusCounts: statusCounts,
    );
  }

  List<String> _buildInsights(_DashboardStats stats) {
    final insights = <String>[];

    if (stats.thisMonthTotal > 0 || stats.growthPercent != 0) {
      final direction = stats.growthPercent >= 0 ? 'up' : 'down';
      insights.add(
        'Sales revenue is $direction ${stats.growthPercent.abs().toStringAsFixed(1)}% '
        'compared to last month.',
      );
    }

    if (stats.avgDisplayDurationDays != null) {
      insights.add(
        'Items typically sell after ${stats.avgDisplayDurationDays!.round()} days in inventory.',
      );
    }

    if (stats.fastMovingCount > 0 || stats.slowMovingCount > 0) {
      insights.add(
        '${stats.fastMovingCount} item(s) sold within a month of being added; '
        '${stats.slowMovingCount} took over two months.',
      );
    }

    insights.add(
      '${(stats.turnoverRate * 100).toStringAsFixed(1)}% of current inventory has sold so far.',
    );

    if (stats.activeConsignedItems > 0) {
      insights.add('${stats.activeConsignedItems} consigned item(s) are still active.');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: AppRepositories.inventory.watchAll(),
      builder: (context, inventorySnap) {
        return StreamBuilder<List<ConsignmentItem>>(
          stream: AppRepositories.consignments.watchAll(),
          builder: (context, consignmentSnap) {
            return StreamBuilder<List<SalesTransaction>>(
              stream: AppRepositories.salesTransactions.watchAll(),
              builder: (context, transactionsSnap) {
                return StreamBuilder<List<ClientInquiry>>(
                  stream: AppRepositories.clientInquiries.watchAll(),
                  builder: (context, inquiriesSnap) {
                    final stats = _computeStats(
                      inventorySnap.data ?? const <InventoryItem>[],
                      consignmentSnap.data ?? const <ConsignmentItem>[],
                      transactionsSnap.data ?? const <SalesTransaction>[],
                      inquiriesSnap.data ?? const <ClientInquiry>[],
                    );
                    final insights = _buildInsights(stats);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        final bool isWide = width >= 900;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${AppSession.instance.username ?? 'User'}!',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildTopStatsRow(isWide, stats),
                              const SizedBox(height: 20),
                              _buildChartsRow(isWide, stats),
                              const SizedBox(height: 20),
                              _buildSmallStatsRow(width, stats),
                              const SizedBox(height: 20),
                              _buildBottomRow(isWide, stats, insights),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatAmount(double amount) {
    final wholeNumber = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < wholeNumber.length; i++) {
      final posFromEnd = wholeNumber.length - i;
      buffer.write(wholeNumber[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  Widget _buildTopStatsRow(bool isWide, _DashboardStats stats) {
    final cards = <Widget>[
      StatCard(
        title: 'Total Sales',
        value: _formatAmount(stats.thisMonthTotal),
        prefixSymbol: '₱',
      ),
      StatCard(title: 'Number of Items Sold', value: '${stats.itemsSold}'),
      StatCard(
        title: 'Active Consigned Items',
        value: '${stats.activeConsignedItems}',
      ),
      StatCard(
        title: 'Monthly Sales Growth',
        value: '${stats.growthPercent.toStringAsFixed(1)}%',
        showTrendUp: stats.growthPercent >= 0,
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 16),
                child: cards[i],
              ),
            ),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [for (final card in cards) SizedBox(width: 240, child: card)],
    );
  }

  Widget _buildChartsRow(bool isWide, _DashboardStats stats) {
    final overview = SalesOverviewChart(
      monthlyTotals: stats.monthlyTotals,
      monthLabels: stats.monthLabels,
    );
    final revenue = MonthlyRevenueChart(
      monthlyTotals: stats.monthlyTotals,
      monthLabels: stats.monthLabels,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: overview),
          const SizedBox(width: 16),
          Expanded(child: revenue),
        ],
      );
    }
    return Column(
      children: [overview, const SizedBox(height: 16), revenue],
    );
  }

  Widget _buildSmallStatsRow(double width, _DashboardStats stats) {
    final cards = <Widget>[
      StatCard(
        title: 'Average Display Duration',
        value: stats.avgDisplayDurationDays == null
            ? '—'
            : stats.avgDisplayDurationDays!.round().toString(),
        suffix: stats.avgDisplayDurationDays == null ? null : 'days',
      ),
      StatCard(
        title: 'Inventory Turnover Rate',
        value: '${stats.turnoverRate.toStringAsFixed(2)}x',
      ),
      StatCard(title: 'Total Item Inquiries', value: '${stats.totalInquiries}'),
      StatCard(title: 'Fast Moving Items', value: '${stats.fastMovingCount}'),
      StatCard(title: 'Slow Moving Items', value: '${stats.slowMovingCount}'),
    ];

    int crossAxisCount;
    double aspectRatio;
    if (width < 600) {
      crossAxisCount = 2;
      aspectRatio = 1.55;
    } else if (width < 900) {
      crossAxisCount = 3;
      aspectRatio = 1.40;
    } else {
      crossAxisCount = 5;
      aspectRatio = 1.45;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: cards,
    );
  }

  Widget _buildBottomRow(bool isWide, _DashboardStats stats, List<String> insights) {
    final performance = InventoryPerformanceChart(statusCounts: stats.statusCounts);
    final actualVsAverage = ActualVsPredictedChart(
      monthlyTotals: stats.monthlyTotals,
      monthLabels: stats.monthLabels,
    );
    final keyInsights = KeyInsightsCard(insights: insights);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: performance),
          const SizedBox(width: 16),
          Expanded(flex: 4, child: actualVsAverage),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: keyInsights),
        ],
      );
    }
    return Column(
      children: [
        performance,
        const SizedBox(height: 16),
        actualVsAverage,
        const SizedBox(height: 16),
        keyInsights,
      ],
    );
  }
}
