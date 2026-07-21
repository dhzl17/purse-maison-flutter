import 'package:flutter/material.dart';

import '../models/consignment_item.dart';
import '../services/app_repositories.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/common_widgets.dart';
import '../widgets/consignment_item_dialog.dart';
import '../widgets/consignment_table.dart';
import '../widgets/dialog_widgets.dart';

class ConsignmentManagementPage extends StatefulWidget {
  const ConsignmentManagementPage({super.key});

  @override
  State<ConsignmentManagementPage> createState() =>
      _ConsignmentManagementPageState();
}

class _ConsignmentManagementPageState extends State<ConsignmentManagementPage> {
  bool _showAll = false;

  String _nextItemId(List<ConsignmentItem> items) {
    int maxNum = 0;
    for (final item in items) {
      final n = int.tryParse(item.itemId) ?? 0;
      if (n > maxNum) maxNum = n;
    }
    return maxNum == 0 ? '1101' : '${maxNum + 1}';
  }

  Future<void> _handleDelete(ConsignmentItem item) async {
    final confirmed =
        await confirmDelete(context: context, itemLabel: '${item.itemName} (${item.itemId})');
    if (!confirmed) return;
    try {
      await AppRepositories.consignments.delete(item.itemId);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 1,
      body: StreamBuilder<List<ConsignmentItem>>(
        stream: AppRepositories.consignments.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load consignments: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? const <ConsignmentItem>[];
          final visibleItems = _showAll ? items : items.take(6).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consignment Management',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(child: SortByRow(value: 'Recently')),
                    AddEntityButton(
                      label: 'Add Item',
                      onPressed: () => showConsignmentItemDialog(
                        context,
                        nextItemId: _nextItemId(items),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ConsignmentTable(
                  items: visibleItems,
                  onEdit: (item) => showConsignmentItemDialog(context, existing: item),
                  onDelete: _handleDelete,
                ),
                const SizedBox(height: 12),
                if (items.length > 6)
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showAll = !_showAll),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showAll ? 'Show less' : 'Show all',
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            _showAll
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.textDark,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
