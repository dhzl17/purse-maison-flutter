import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ============================================================================
// STAT CARD 
// ============================================================================
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? prefixSymbol; // e.g. "₱"
  final String? suffix; // e.g. "days"
  final bool showTrendUp;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.prefixSymbol,
    this.suffix,
    this.showTrendUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardNavyLight, AppColors.cardNavyDark],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTrendUp)
                const Padding(
                  padding: EdgeInsets.only(right: 4, bottom: 4),
                  child: Icon(
                    Icons.arrow_upward,
                    color: AppColors.green,
                    size: 18,
                  ),
                ),
              if (prefixSymbol != null)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    prefixSymbol!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 3),
                  child: Text(
                    suffix!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CHART CARD 
// ============================================================================
class ChartCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ChartCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PeriodChip extends StatelessWidget {
  final String label;
  const PeriodChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class SortByRow extends StatelessWidget {
  final String value;
  const SortByRow({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sort by: ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            color: AppColors.textDark,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
        ),
        const SizedBox(width: 2),
        const Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: AppColors.textMuted,
        ),
      ],
    );
  }
}

// ============================================================================
// STATUS BADGE 
// ============================================================================
enum StatusBadgeTone { success, danger, warning, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeTone tone;

  const StatusBadge({super.key, required this.label, required this.tone});

  Color get _color {
    if (tone == StatusBadgeTone.success) return AppColors.green;
    if (tone == StatusBadgeTone.danger) return AppColors.dangerRed;
    if (tone == StatusBadgeTone.info) return AppColors.chartBlueMed;
    return AppColors.warningAmber;
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

// ============================================================================
// VIEW ALL LINK 
// ============================================================================
class ViewAllLink extends StatelessWidget {
  final VoidCallback? onTap;
  const ViewAllLink({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(
          'View All',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class NavyActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;

  const NavyActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cardNavyDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
    );
    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

// ============================================================================
// LABELED DROPDOWN
// ============================================================================
class LabeledDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.textMuted,
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTIVITY FEED CARD 
// ============================================================================
class FeedEntry {
  final String description;
  final String timestamp;
  const FeedEntry({required this.description, required this.timestamp});
}

class ActivityFeedCard extends StatelessWidget {
  final String title;
  final List<FeedEntry> entries;
  final VoidCallback? onViewAll;

  const ActivityFeedCard({
    super.key,
    required this.title,
    required this.entries,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (onViewAll != null) ViewAllLink(onTap: onViewAll),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < entries.length; i++) ...[
            _FeedRow(entry: entries[i]),
            if (i != entries.length - 1)
              const Divider(height: 22, color: AppColors.borderLight),
          ],
        ],
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  final FeedEntry entry;
  const _FeedRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            entry.description,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          entry.timestamp,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ============================================================================
// TABLE CARD 
// ============================================================================
class TableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onViewAll;

  const TableCard({super.key, required this.child, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          if (onViewAll != null) ...[
            const SizedBox(height: 12),
            Center(child: ViewAllLink(onTap: onViewAll)),
          ],
        ],
      ),
    );
  }
}
