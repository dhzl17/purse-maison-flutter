import 'package:flutter/material.dart';

import '../models/sales_forecast.dart';
import '../theme/app_colors.dart';
import 'dialog_widgets.dart';

const double _colBrand = 130;
const double _colHistorical = 130;
const double _colProjected = 130;
const double _colGrowth = 110;
const double _colTrendMin = 140;
const double _colActions = 100;
const double _fixedTotal =
    _colBrand + _colHistorical + _colProjected + _colGrowth;
const double _minTableWidth = _fixedTotal + _colTrendMin;
const double _minTableWidthWithActions = _minTableWidth + _colActions;

const TextStyle _bodyStyle = TextStyle(fontSize: 13, color: AppColors.textDark);
const TextStyle _bodyStyleBold = TextStyle(
  fontSize: 13,
  color: AppColors.textDark,
  fontWeight: FontWeight.w700,
);

class ForecastTable extends StatelessWidget {
  final List<BrandForecast> items;
  final void Function(BrandForecast item)? onEdit;
  final void Function(BrandForecast item)? onDelete;

  const ForecastTable({super.key, required this.items, this.onEdit, this.onDelete});

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
          child: _buildTable(expandTrend: fits),
        );
        if (fits) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }

  Widget _buildTable({required bool expandTrend}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderRow(expandTrend: expandTrend, showActions: _editable),
            for (int i = 0; i < items.length; i++)
              _DataRow(
                item: items[i],
                expandTrend: expandTrend,
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
  final bool expandTrend;
  final bool showActions;
  const _HeaderRow({required this.expandTrend, required this.showActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardNavyDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerCell('Brand', width: _colBrand),
          _headerCell(
            'Historical Sales',
            width: _colHistorical,
            subtitle: 'Last 6 Months',
          ),
          _headerCell(
            'Projected Sales',
            width: _colProjected,
            subtitle: 'Next 3 Months',
          ),
          _headerCell('Projected Growth (%)', width: _colGrowth),
          _headerCell('Demand Trend', width: _colTrendMin, expand: expandTrend),
          if (showActions) _headerCell('Actions', width: _colActions),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label, {
    required double width,
    bool expand = false,
    String? subtitle,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
    if (expand) return Expanded(child: content);
    return SizedBox(width: width, child: content);
  }
}

class _DataRow extends StatelessWidget {
  final BrandForecast item;
  final bool expandTrend;
  final bool isLast;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DataRow({
    required this.item,
    required this.expandTrend,
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
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cell(Text(item.brand, style: _bodyStyleBold), width: _colBrand),
            _cell(
              Text(item.historicalSales, style: _bodyStyle),
              width: _colHistorical,
            ),
            _cell(
              Text(item.projectedSales, style: _bodyStyle),
              width: _colProjected,
            ),
            _cell(_growthText(item.projectedGrowthPercent), width: _colGrowth),
            _cell(
              _trendCell(item.trend),
              width: _colTrendMin,
              expand: expandTrend,
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

  Widget _growthText(double percent) {
    final bool positive = percent >= 0;
    final String text = '${positive ? '+' : ''}${percent.toStringAsFixed(1)}%';
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: positive ? AppColors.green : AppColors.dangerRed,
      ),
    );
  }

  Widget _trendCell(DemandTrend trend) {
    IconData icon;
    Color color;
    String label;
    if (trend == DemandTrend.increasing) {
      icon = Icons.arrow_upward;
      color = AppColors.green;
      label = 'Increasing';
    } else if (trend == DemandTrend.decreasing) {
      icon = Icons.arrow_downward;
      color = AppColors.dangerRed;
      label = 'Decreasing';
    } else {
      icon = Icons.arrow_forward;
      color = AppColors.textDark;
      label = 'Stable';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
