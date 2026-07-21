import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TablePagination extends StatelessWidget {
  final int currentPage; // 1-based
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const TablePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<int> _visiblePages() {
    if (totalPages <= 5) {
      return List.generate(totalPages, (i) => i + 1);
    }
    return [1, 2, 3, -1, totalPages];
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconButton(
              Icons.first_page,
              currentPage > 1 ? () => onPageChanged(1) : null,
            ),
            _iconButton(
              Icons.chevron_left,
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            for (final p in _visiblePages())
              p == -1
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '…',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : _pageButton(p),
            _iconButton(
              Icons.chevron_right,
              currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
            ),
            _iconButton(
              Icons.last_page,
              currentPage < totalPages ? () => onPageChanged(totalPages) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageButton(int page) {
    final bool active = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: active ? AppColors.cardNavyDark : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onPageChanged(page),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Text(
              '$page',
              style: TextStyle(
                color: active ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, size: 18),
      color: AppColors.textDark,
      disabledColor: AppColors.textMuted.withValues(alpha: 0.4),
      onPressed: onTap,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
