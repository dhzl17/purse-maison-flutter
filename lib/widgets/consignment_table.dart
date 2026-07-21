import 'package:flutter/material.dart';

import '../models/consignment_item.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';
import 'dialog_widgets.dart';


const double _colItemId = 70;
const double _colBrand = 120;
const double _colDetailsMin = 180;
const double _colAuth = 150;
const double _colStatus = 150;
const double _colPrice = 110;
const double _colPayout = 150;
const double _colActions = 100;
const double _fixedColsTotal =
    _colItemId + _colBrand + _colAuth + _colStatus + _colPrice + _colPayout;
const double _minTableWidth = _fixedColsTotal + _colDetailsMin;
const double _minTableWidthWithActions = _minTableWidth + _colActions;

const TextStyle _bodyStyle = TextStyle(fontSize: 13, color: AppColors.textDark);
const TextStyle _bodyStyleBold = TextStyle(
  fontSize: 13,
  color: AppColors.textDark,
  fontWeight: FontWeight.w700,
);
const TextStyle _labelStyle = TextStyle(
  fontSize: 12.5,
  color: AppColors.textDark,
  fontWeight: FontWeight.w700,
);
const TextStyle _valueStyle = TextStyle(fontSize: 12.5, color: AppColors.textDark);
const TextStyle _valueStyleBold = TextStyle(
  fontSize: 12.5,
  color: AppColors.textDark,
  fontWeight: FontWeight.w700,
);


class ConsignmentTable extends StatelessWidget {
  final List<ConsignmentItem> items;
  final void Function(ConsignmentItem item)? onEdit;
  final void Function(ConsignmentItem item)? onDelete;

  const ConsignmentTable({super.key, required this.items, this.onEdit, this.onDelete});

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
          child: _buildTable(expandDetails: fits),
        );
        if (fits) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }

  Widget _buildTable({required bool expandDetails}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderRow(expandDetails: expandDetails, showActions: _editable),
            for (int i = 0; i < items.length; i++)
              _DataRow(
                item: items[i],
                expandDetails: expandDetails,
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
  final bool expandDetails;
  final bool showActions;
  const _HeaderRow({required this.expandDetails, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardNavyDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerCell('Item ID', width: _colItemId),
          _headerCell('Brand', width: _colBrand),
          _headerCell('Details', width: _colDetailsMin, expand: expandDetails),
          _headerCell('Authentication', width: _colAuth),
          _headerCell('Status', width: _colStatus),
          _headerCell('Price', width: _colPrice),
          _headerCell('Payout Status', width: _colPayout),
          if (showActions) _headerCell('Actions', width: _colActions),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required double width, bool expand = false}) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
      ),
    );
    if (expand) return Expanded(child: content);
    return SizedBox(width: width, child: content);
  }
}

class _DataRow extends StatelessWidget {
  final ConsignmentItem item;
  final bool expandDetails;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DataRow({
    required this.item,
    required this.expandDetails,
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
              _DetailsCell(item: item),
              width: _colDetailsMin,
              expand: expandDetails,
            ),
            _cell(
              Center(child: _authBadge(item.authentication)),
              width: _colAuth,
            ),
            _cell(
              Center(
                child: Text(item.status, textAlign: TextAlign.center, style: _bodyStyle),
              ),
              width: _colStatus,
            ),
            _cell(
              Center(child: Text(item.price, style: _bodyStyleBold)),
              width: _colPrice,
            ),
            _cell(
              Center(child: _payoutBadge(item.payoutStatus)),
              width: _colPayout,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  Widget _authBadge(AuthenticationStatus status) {
    if (status == AuthenticationStatus.verified) {
      return const StatusBadge(label: 'Verified', tone: StatusBadgeTone.success);
    }
    return const StatusBadge(label: 'Rejected', tone: StatusBadgeTone.danger);
  }

  Widget _payoutBadge(PayoutStatus status) {
    if (status == PayoutStatus.sold) {
      return const StatusBadge(label: 'Sold', tone: StatusBadgeTone.success);
    }
    if (status == PayoutStatus.cancelled) {
      return const StatusBadge(label: 'Cancelled', tone: StatusBadgeTone.danger);
    }
    return const StatusBadge(label: 'Not Yet Sold', tone: StatusBadgeTone.warning);
  }
}

class _DetailsCell extends StatelessWidget {
  final ConsignmentItem item;
  const _DetailsCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.imagePath,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              color: AppColors.chipBackground,
              child: const Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Item Name: ', style: _labelStyle),
                    TextSpan(text: item.itemName, style: _valueStyle),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Category: ', style: _labelStyle),
                    TextSpan(text: item.category, style: _valueStyleBold),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Condition: ', style: _labelStyle),
                    TextSpan(text: item.condition, style: _valueStyleBold),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
