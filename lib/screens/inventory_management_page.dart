import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../models/sales_transaction.dart';
import '../models/user_role.dart';
import '../services/app_repositories.dart';
import '../services/app_session.dart';
import '../services/chart_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/inventory_charts.dart';
import '../widgets/inventory_item_dialog.dart';
import '../widgets/inventory_table.dart';
import '../widgets/table_pagination.dart';

class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({super.key});

  @override
  State<InventoryManagementPage> createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage> {
  static const int _pageSize = 6;
  int _currentPage = 1;

  bool get _viewOnly =>
      AppSession.instance.currentRole?.inventoryIsViewOnly ?? false;

  String _nextItemId(List<InventoryItem> items) {
    int maxNum = 0;
    for (final item in items) {
      final match = RegExp(r'INV-(\d+)').firstMatch(item.itemId);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxNum) maxNum = n;
      }
    }
    return 'INV-${(maxNum + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _handleDelete(InventoryItem item) async {
    final confirmed = await confirmDelete(context: context, itemLabel: '${item.brand} (${item.itemId})');
    if (!confirmed) return;
    try {
      await AppRepositories.inventory.delete(item.itemId);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  static DateTime? _parseDateAdded(String s) {
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final m = int.tryParse(parts[0]);
    final d = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (m == null || d == null || y == null) return null;
    return DateTime(y, m, d);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 2,
      body: StreamBuilder<List<InventoryItem>>(
        stream: AppRepositories.inventory.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load inventory: ${snapshot.error}'));
          }

          final allItems = snapshot.data ?? const <InventoryItem>[];
          final int totalPages = allItems.isEmpty
              ? 1
              : (allItems.length / _pageSize).ceil();
          final int safePage = _currentPage.clamp(1, totalPages);
          final int start = (safePage - 1) * _pageSize;
          final int end = (start + _pageSize).clamp(0, allItems.length).toInt();
          final List<InventoryItem> pageItems = allItems.sublist(start, end);

          return StreamBuilder<List<SalesTransaction>>(
            stream: AppRepositories.salesTransactions.watchAll(),
            builder: (context, txnSnapshot) {
              final transactions = txnSnapshot.data ?? const <SalesTransaction>[];

              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 900;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventory Management',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildKpiRow(isWide, allItems),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: SortByRow(value: 'Recently')),
                            if (!_viewOnly)
                              AddEntityButton(
                                label: 'Add Item',
                                onPressed: () => showInventoryItemDialog(
                                  context,
                                  nextItemId: _nextItemId(allItems),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        InventoryTable(
                          items: pageItems,
                          onEdit: _viewOnly
                              ? null
                              : (item) => showInventoryItemDialog(context, existing: item),
                          onDelete: _viewOnly ? null : _handleDelete,
                        ),
                        const SizedBox(height: 10),
                        TablePagination(
                          currentPage: safePage,
                          totalPages: totalPages,
                          onPageChanged: (page) => setState(() => _currentPage = page),
                        ),
                        const SizedBox(height: 20),
                        _buildBottomRow(isWide, allItems, transactions),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildKpiRow(bool isWide, List<InventoryItem> items) {
    final int total = items.length;
    final int available =
        items.where((i) => i.status == InventoryStatus.available).length;
    final int reserved =
        items.where((i) => i.status == InventoryStatus.reserved).length;
    const int lowStock = 0;

    final cards = <Widget>[
      StatCard(title: 'Total Items', value: '$total'),
      StatCard(title: 'Available Items', value: '$available'),
      StatCard(title: 'Reserved Items', value: '$reserved'),
      StatCard(title: 'Low Stock Items', value: '$lowStock'),
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
      children: [for (final card in cards) SizedBox(width: 220, child: card)],
    );
  }

  Widget _buildBottomRow(
    bool isWide,
    List<InventoryItem> items,
    List<SalesTransaction> transactions,
  ) {
    final Map<String, int> byLocation = {};
    for (final item in items) {
      byLocation[item.location] = (byLocation[item.location] ?? 0) + 1;
    }
    final locationCounts = byLocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final months = lastNMonths(6);
    final monthLabels = [for (final m in months) m.label];
    final soldCounts = monthlySoldCounts(transactions, months);
    final turnoverByMonth = [
      for (final count in soldCounts)
        items.isEmpty ? 0.0 : (count / items.length) * 100,
    ];

    final inventoryById = {for (final item in items) item.itemId: item};
    final leaderboardEntries = <TurnoverEntry>[];
    for (final t in transactions) {
      if (t.itemId == null) continue;
      final item = inventoryById[t.itemId];
      if (item == null) continue;
      final addedDate = _parseDateAdded(item.dateAdded);
      if (addedDate == null) continue;
      final days = t.date.difference(addedDate).inDays;
      if (days < 0) continue;
      leaderboardEntries.add(
        TurnoverEntry(name: '${item.brand} ${item.category}', days: days, price: item.price),
      );
    }
    leaderboardEntries.sort((a, b) => b.days.compareTo(a.days));
    final topLeaderboardEntries = leaderboardEntries.take(5).toList();

    final locationChart = InventoryByLocationChart(counts: locationCounts);
    final turnoverChart = InventoryTurnoverLineChart(
      turnoverPercentByMonth: turnoverByMonth,
      monthLabels: monthLabels,
    );
    final leaderboard = TurnoverLeaderboardCard(entries: topLeaderboardEntries);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: locationChart),
          const SizedBox(width: 16),
          Expanded(flex: 4, child: turnoverChart),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: leaderboard),
        ],
      );
    }
    return Column(
      children: [
        locationChart,
        const SizedBox(height: 16),
        turnoverChart,
        const SizedBox(height: 16),
        leaderboard,
      ],
    );
  }
}
