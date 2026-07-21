import 'package:flutter/material.dart';

import '../models/client_assignment.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';
import 'dialog_widgets.dart';

const TextStyle _bodyStyle = TextStyle(fontSize: 13, color: AppColors.textDark);
const TextStyle _bodyStyleBold = TextStyle(
  fontSize: 13,
  color: AppColors.textDark,
  fontWeight: FontWeight.w700,
);
const TextStyle _mutedStyle = TextStyle(fontSize: 13, color: AppColors.textMuted);

Widget _headerCell(String label, {required double width, bool expand = false}) {
  final content = Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
    ),
  );
  if (expand) return Expanded(child: content);
  return SizedBox(width: width, child: content);
}

Widget _dataCell(
  Widget child, {
  required double width,
  bool expand = false,
  bool isLastColumn = false,
}) {
  final content = Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      border: isLastColumn ? null : const Border(right: BorderSide(color: AppColors.borderLight)),
    ),
    child: child,
  );
  if (expand) return Expanded(child: content);
  return SizedBox(width: width, child: content);
}

// ============================================================================
// TABLE 1 — Client Inquiries
// ============================================================================
const double _ciColNo = 44;
const double _ciColName = 130;
const double _ciColType = 90;
const double _ciColRole = 100;
// These columns contain padded status badges.  Leave enough room for the
// badge label as well as the cell padding so the badge never overflows.
const double _ciColInquiryStatus = 132;
const double _ciColSourceMin = 110;
const double _ciColTransaction = 150;
const double _ciColActions = 100;
const double _ciFixedTotal =
    _ciColNo + _ciColName + _ciColType + _ciColRole + _ciColInquiryStatus + _ciColTransaction;
const double _ciMinTableWidth = _ciFixedTotal + _ciColSourceMin;
const double _ciMinTableWidthWithActions = _ciMinTableWidth + _ciColActions;

class ClientInquiryTable extends StatelessWidget {
  final List<ClientInquiry> items;
  final void Function(ClientInquiry item)? onEdit;
  final void Function(ClientInquiry item)? onDelete;

  const ClientInquiryTable({super.key, required this.items, this.onEdit, this.onDelete});

  bool get _editable => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final double minWidth = _editable ? _ciMinTableWidthWithActions : _ciMinTableWidth;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool fits = constraints.maxWidth >= minWidth;
        final double tableWidth = fits ? constraints.maxWidth : minWidth + 2.0;
        final Widget table = SizedBox(
          width: tableWidth,
          child: _buildTable(expandSource: fits),
        );
        if (fits) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }

  Widget _buildTable({required bool expandSource}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ClientInquiryHeaderRow(expandSource: expandSource, showActions: _editable),
            for (int i = 0; i < items.length; i++)
              _ClientInquiryDataRow(
                item: items[i],
                expandSource: expandSource,
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

class _ClientInquiryHeaderRow extends StatelessWidget {
  final bool expandSource;
  final bool showActions;
  const _ClientInquiryHeaderRow({required this.expandSource, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardNavyDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerCell('No.', width: _ciColNo),
          _headerCell('Client Name', width: _ciColName),
          _headerCell('Client Type', width: _ciColType),
          _headerCell('Client Role', width: _ciColRole),
          _headerCell('Inquiry Status', width: _ciColInquiryStatus),
          _headerCell('Inquiry Source', width: _ciColSourceMin, expand: expandSource),
          _headerCell('Transaction Result', width: _ciColTransaction),
          if (showActions) _headerCell('Actions', width: _ciColActions),
        ],
      ),
    );
  }
}

class _ClientInquiryDataRow extends StatelessWidget {
  final ClientInquiry item;
  final bool expandSource;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ClientInquiryDataRow({
    required this.item,
    required this.expandSource,
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
            _dataCell(Text('${item.no}', style: _bodyStyle), width: _ciColNo),
            _dataCell(Text(item.clientName, style: _bodyStyleBold), width: _ciColName),
            _dataCell(
              Center(child: Text(item.clientType, textAlign: TextAlign.center, style: _bodyStyle)),
              width: _ciColType,
            ),
            _dataCell(
              Center(child: Text(item.clientRole, textAlign: TextAlign.center, style: _bodyStyle)),
              width: _ciColRole,
            ),
            _dataCell(
              Center(child: _inquiryStatusBadge(item.inquiryStatus)),
              width: _ciColInquiryStatus,
            ),
            _dataCell(
              Center(
                child: Text(item.inquirySource, textAlign: TextAlign.center, style: _bodyStyle),
              ),
              width: _ciColSourceMin,
              expand: expandSource,
            ),
            _dataCell(
              Center(child: _transactionResultCell(item.transactionResult)),
              width: _ciColTransaction,
              isLastColumn: !showActions,
            ),
            if (showActions)
              _dataCell(
                Center(child: RowActionButtons(onEdit: onEdit, onDelete: onDelete)),
                width: _ciColActions,
                isLastColumn: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _inquiryStatusBadge(InquiryStatus status) {
    if (status == InquiryStatus.newInquiry) {
      return const StatusBadge(label: 'New', tone: StatusBadgeTone.warning);
    }
    if (status == InquiryStatus.closed) {
      return const StatusBadge(label: 'Closed', tone: StatusBadgeTone.danger);
    }
    if (status == InquiryStatus.followedUp) {
      return const StatusBadge(label: 'Followed-up', tone: StatusBadgeTone.info);
    }
    return const StatusBadge(label: 'Reserved', tone: StatusBadgeTone.success);
  }

  Widget _transactionResultCell(TransactionResult result) {
    if (result == TransactionResult.none) {
      return Text('-', textAlign: TextAlign.center, style: _mutedStyle);
    }
    if (result == TransactionResult.noPurchase) {
      return const StatusBadge(label: 'No Purchase', tone: StatusBadgeTone.danger);
    }
    return const StatusBadge(label: 'Purchased', tone: StatusBadgeTone.success);
  }
}

// ============================================================================
// TABLE 2 — Sales Associates
// ============================================================================
const double _saColAssociate = 150;
const double _saColStatus = 126;
const double _saColClientMin = 140;
const double _saColActions = 100;
const double _saFixedTotal = _saColAssociate + _saColStatus;
const double _saMinTableWidth = _saFixedTotal + _saColClientMin;
const double _saMinTableWidthWithActions = _saMinTableWidth + _saColActions;

class SalesAssociateTable extends StatelessWidget {
  final List<SalesAssociateAssignment> items;
  final void Function(SalesAssociateAssignment item)? onEdit;
  final void Function(SalesAssociateAssignment item)? onDelete;

  const SalesAssociateTable({super.key, required this.items, this.onEdit, this.onDelete});

  bool get _editable => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final double minWidth = _editable ? _saMinTableWidthWithActions : _saMinTableWidth;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool fits = constraints.maxWidth >= minWidth;
        final double tableWidth = fits ? constraints.maxWidth : minWidth + 2.0;
        final Widget table = SizedBox(
          width: tableWidth,
          child: _buildTable(expandClient: fits),
        );
        if (fits) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }

  Widget _buildTable({required bool expandClient}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SalesAssociateHeaderRow(expandClient: expandClient, showActions: _editable),
            for (int i = 0; i < items.length; i++)
              _SalesAssociateDataRow(
                item: items[i],
                expandClient: expandClient,
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

class _SalesAssociateHeaderRow extends StatelessWidget {
  final bool expandClient;
  final bool showActions;
  const _SalesAssociateHeaderRow({required this.expandClient, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardNavyDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerCell('Sales Associate', width: _saColAssociate),
          _headerCell('Status', width: _saColStatus),
          _headerCell('Current Client', width: _saColClientMin, expand: expandClient),
          if (showActions) _headerCell('Actions', width: _saColActions),
        ],
      ),
    );
  }
}

class _SalesAssociateDataRow extends StatelessWidget {
  final SalesAssociateAssignment item;
  final bool expandClient;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SalesAssociateDataRow({
    required this.item,
    required this.expandClient,
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
            _dataCell(Text(item.associateName, style: _bodyStyleBold), width: _saColAssociate),
            _dataCell(Center(child: _statusBadge(item.status)), width: _saColStatus),
            _dataCell(
              Text(
                item.currentClient,
                style: item.currentClient == '-' ? _mutedStyle : _bodyStyle,
              ),
              width: _saColClientMin,
              expand: expandClient,
              isLastColumn: !showActions,
            ),
            if (showActions)
              _dataCell(
                Center(child: RowActionButtons(onEdit: onEdit, onDelete: onDelete)),
                width: _saColActions,
                isLastColumn: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(AssociateStatus status) {
    if (status == AssociateStatus.assigned) {
      return const StatusBadge(label: 'Assigned', tone: StatusBadgeTone.success);
    }
    return const StatusBadge(label: 'Available', tone: StatusBadgeTone.warning);
  }
}
