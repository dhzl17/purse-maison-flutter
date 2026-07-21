import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common_widgets.dart';

// ============================================================================
// QUICK ACTIONS — two full-width navy buttons.
// (Recent Assignment Activity now uses the generic ActivityFeedCard from
// common_widgets.dart directly — see client_assignment_page.dart.)
// ============================================================================
class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onAddWalkInClient;
  final VoidCallback? onAddOnlineInquiry;

  const QuickActionsCard({super.key, this.onAddWalkInClient, this.onAddOnlineInquiry});

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          const SizedBox(height: 20),
          NavyActionButton(
            label: '+ Add Walk In Client',
            onPressed: onAddWalkInClient ??
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Walk In Client tapped')),
                    ),
          ),
          const SizedBox(height: 14),
          NavyActionButton(
            label: '+ Add Online Inquiry',
            onPressed: onAddOnlineInquiry ??
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Online Inquiry tapped')),
                    ),
          ),
        ],
      ),
    );
  }
}
