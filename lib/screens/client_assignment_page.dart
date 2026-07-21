import 'package:flutter/material.dart';

import '../models/client_assignment.dart';
import '../services/app_repositories.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/client_assignment_dialogs.dart';
import '../widgets/client_assignment_panels.dart';
import '../widgets/client_assignment_tables.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialog_widgets.dart';

/// The Client Assignment screen (sidebar index 3).
class ClientAssignmentPage extends StatelessWidget {
  const ClientAssignmentPage({super.key});

  int _nextInquiryNo(List<ClientInquiry> inquiries) {
    int maxNo = 0;
    for (final i in inquiries) {
      if (i.no > maxNo) maxNo = i.no;
    }
    return maxNo + 1;
  }

  Future<void> _handleDeleteInquiry(BuildContext context, ClientInquiry item) async {
    final confirmed = await confirmDelete(context: context, itemLabel: item.clientName);
    if (!confirmed) return;
    try {
      await AppRepositories.clientInquiries.delete(item.id);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  Future<void> _handleDeleteAssociate(
    BuildContext context,
    SalesAssociateAssignment item,
  ) async {
    final confirmed = await confirmDelete(context: context, itemLabel: item.associateName);
    if (!confirmed) return;
    try {
      await AppRepositories.salesAssociates.delete(item.id);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 3,
      body: StreamBuilder<List<ClientInquiry>>(
        stream: AppRepositories.clientInquiries.watchAll(),
        builder: (context, inquirySnap) {
          return StreamBuilder<List<SalesAssociateAssignment>>(
            stream: AppRepositories.salesAssociates.watchAll(),
            builder: (context, associateSnap) {
              return StreamBuilder<List<FeedEntryRecord>>(
                stream: AppRepositories.assignmentActivity.watchAll(),
                builder: (context, activitySnap) {
                  final loading = inquirySnap.connectionState ==
                          ConnectionState.waiting ||
                      associateSnap.connectionState ==
                          ConnectionState.waiting ||
                      activitySnap.connectionState == ConnectionState.waiting;

                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final error = inquirySnap.error ??
                      associateSnap.error ??
                      activitySnap.error;
                  if (error != null) {
                    return Center(child: Text('Failed to load: $error'));
                  }

                  final inquiries =
                      inquirySnap.data ?? const <ClientInquiry>[];
                  final associates = associateSnap.data ??
                      const <SalesAssociateAssignment>[];
                  final activity =
                      (activitySnap.data ?? const <FeedEntryRecord>[])
                          .map((e) => FeedEntry(
                                description: e.description,
                                timestamp: e.timestamp,
                              ))
                          .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth >= 1000;
                      // Both tables need enough room for their headers and
                      // status badges. Stack them before the narrower
                      // sales-associate table is squeezed.
                      final bool canShowTablesSideBySide =
                          constraints.maxWidth >= 1280;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Client Assignment',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SortByRow(value: 'Recently'),
                            const SizedBox(height: 14),
                            _buildTablesRow(
                              context,
                              canShowTablesSideBySide,
                              inquiries,
                              associates,
                            ),
                            const SizedBox(height: 20),
                            _buildBottomRow(context, isWide, inquiries, activity),
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
      ),
    );
  }

  Widget _buildTablesRow(
    BuildContext context,
    bool isWide,
    List<ClientInquiry> inquiries,
    List<SalesAssociateAssignment> associates,
  ) {
    final Widget left = TableCard(
      onViewAll: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing all client inquiries')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AddEntityButton(
              label: 'Add Inquiry',
              onPressed: () => showClientInquiryDialog(
                context,
                nextNo: _nextInquiryNo(inquiries),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClientInquiryTable(
            items: inquiries,
            onEdit: (item) => showClientInquiryDialog(context, existing: item),
            onDelete: (item) => _handleDeleteInquiry(context, item),
          ),
        ],
      ),
    );
    final Widget right = TableCard(
      onViewAll: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing all sales associates')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AddEntityButton(
              label: 'Add Associate',
              onPressed: () => showSalesAssociateDialog(context),
            ),
          ),
          const SizedBox(height: 12),
          SalesAssociateTable(
            items: associates,
            onEdit: (item) => showSalesAssociateDialog(context, existing: item),
            onDelete: (item) => _handleDeleteAssociate(context, item),
          ),
        ],
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: left),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: right),
        ],
      );
    }
    return Column(
      children: [left, const SizedBox(height: 16), right],
    );
  }

  Widget _buildBottomRow(
    BuildContext context,
    bool isWide,
    List<ClientInquiry> inquiries,
    List<FeedEntry> activity,
  ) {
    final Widget activityCard = ActivityFeedCard(
      title: 'Recent Assignment Activity',
      entries: activity,
      onViewAll: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing all assignment activity')),
      ),
    );

    final Widget quickActions = QuickActionsCard(
      onAddWalkInClient: () => showClientInquiryDialog(
        context,
        nextNo: _nextInquiryNo(inquiries),
        initialClientType: 'Walk-in',
      ),
      onAddOnlineInquiry: () => showClientInquiryDialog(
        context,
        nextNo: _nextInquiryNo(inquiries),
        initialClientType: 'Online',
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: quickActions),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: activityCard),
        ],
      );
    }
    return Column(
      children: [
        quickActions,
        const SizedBox(height: 16),
        activityCard,
      ],
    );
  }
}
