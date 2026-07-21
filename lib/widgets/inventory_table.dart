import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';
import 'dialog_widgets.dart';

const double _colItemId = 90;
const double _colBrand = 130;
const double _colCategoryMin = 120;
const double _colCondition = 100;
const double _colStatus = 130;
const double _colLocation = 110;
const double _colDateAdded = 110;
const double _colTransaction = 130;
const double _colPrice = 110;
const double _colActions = 100;
const double _fixedColsTotal = _colItemId +
    _colBrand +
    _colCondition +
    _colStatus +
    _colLocation +
    _colDateAdded +
    _colTransaction +
    _colPrice;
const double _minTableWidth = _fixedColsTotal + _colCategoryMin;
const double _minTableWidthWithActions = _minTableWidth + _colActions;

const TextStyle _bodyStyle = TextStyle(fontSize: 13, color: AppColors.textDark);
const TextStyle _bodyStyleBold = TextStyle(
  fontSize: 13,
  color: AppColors.textDark,
  fontWeight: FontWeight.w700,
);
const TextStyle _mutedStyle = TextStyle(fontSize: 13, color: AppColors.textMuted);

/// The Inventory Management data table. Same responsive pattern as
/// ConsignmentTable: fills available width on wide screens, falls back to
/// horizontal scrolling on narrow ones.
class InventoryTable extends StatelessWidget {
  final List<InventoryItem> items;
  final void Function(InventoryItem item)? onEdit;
  final void Function(InventoryItem item)? onDelete;

  const InventoryTable({super.key, required this.items, this.onEdit, this.onDelete});

  bool get _editable => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final double minWidth = _editable ? _minTableWidthWithActions : _minTableWidth;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool fits = constraints.maxWidth >= minWidth;
        final double tableWidth = fits ? constraints.maxWidth : minWidth + 2.0;
        final Widget table = SizedBox(
          width: tableWidth,
          child: _buildTable(expandCategory: fits),
        );
        if (fits) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }

  Widget _buildTable({required bool expandCategory}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderRow(expandCategory: expandCategory, showActions: _editable),
            for (int i = 0; i < items.length; i++)
              _DataRow(
                item: items[i],
                expandCategory: expandCategory,
                isLast: i == items.length - 1,
                onEdit: onEdit == null ? null : () => onEdit!(items[i]),
                onDelete: onDelete == null ? null : () => onDelete!(items[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final bool expandCategory;
  final bool showActions;
  const _HeaderRow({required this.expandCategory, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardNavyDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerCell('Item ID', width: _colItemId),
          _headerCell('Brand', width: _colBrand),
          _headerCell('Category', width: _colCategoryMin, expand: expandCategory),
          _headerCell('Condition', width: _colCondition),
          _headerCell('Status', width: _colStatus),
          _headerCell('Location', width: _colLocation),
          _headerCell('Date Added', width: _colDateAdded),
          _headerCell('Transaction Status', width: _colTransaction),
          _headerCell('Price', width: _colPrice),
          if (showActions) _headerCell('Actions', width: _colActions),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required double width, bool expand = false}) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
    if (expand) return Expanded(child: content);
    return SizedBox(width: width, child: content);
  }
}

class _DataRow extends StatelessWidget {
  final InventoryItem item;
  final bool expandCategory;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DataRow({
    required this.item,
    required this.expandCategory,
    required this.isLast,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool showActions = onEdit != null || onDelete != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cell(Text(item.itemId, style: _bodyStyle), width: _colItemId),
            _cell(Text(item.brand, style: _bodyStyleBold), width: _colBrand),
            _cell(
              Text(item.category, style: _bodyStyle),
              width: _colCategoryMin,
              expand: expandCategory,
            ),
            _cell(Text(item.condition, style: _bodyStyle), width: _colCondition),
            _cell(Center(child: _statusBadge(item.status)), width: _colStatus),
            _cell(
              Center(child: Text(item.location, textAlign: TextAlign.center, style: _bodyStyle)),
              width: _colLocation,
            ),
            _cell(
              Center(
                child: Text(item.dateAdded, textAlign: TextAlign.center, style: _bodyStyle),
              ),
              width: _colDateAdded,
            ),
            _cell(
              Center(child: _transactionCell(item.transactionStatus)),
              width: _colTransaction,
            ),
            _cell(
              Center(child: Text(item.price, style: _bodyStyleBold)),
              width: _colPrice,
              isLastColumn: !showActions,
            ),
            if (showActions)
              _cell(
                Center(child: RowActionButtons(onEdit: onEdit, onDelete: onDelete)),
                width: _colActions,
                isLastColumn: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    Widget child, {
    required double width,
    bool expand = false,
    bool isLastColumn = false,
  }) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: isLastColumn
            ? null
            : const Border(right: BorderSide(color: AppColors.borderLight)),
      ),
      child: child,
    );
    if (expand) return Expanded(child: content);
    return SizedBox(width: width, child: content);
  }

  Widget _statusBadge(InventoryStatus status) {
    if (status == InventoryStatus.available) {
      return const StatusBadge(label: 'Available', tone: StatusBadgeTone.info);
    }
    if (status == InventoryStatus.reserved) {
      return const StatusBadge(label: 'Reserved', tone: StatusBadgeTone.warning);
    }
    if (status == InventoryStatus.rejected) {
      return const StatusBadge(label: 'Rejected', tone: StatusBadgeTone.danger);
    }
    return const StatusBadge(label: 'Sold', tone: StatusBadgeTone.success);
  }

  Widget _transactionCell(TransactionStatus status) {
    if (status == TransactionStatus.none) {
      return Text('-', textAlign: TextAlign.center, style: _mutedStyle);
    }
    if (status == TransactionStatus.pending) {
      return const StatusBadge(label: 'Pending', tone: StatusBadgeTone.warning);
    }
    if (status == TransactionStatus.cancelled) {
      return const StatusBadge(label: 'Cancelled', tone: StatusBadgeTone.danger);
    }
    return const StatusBadge(label: 'Completed', tone: StatusBadgeTone.success);
  }
}
