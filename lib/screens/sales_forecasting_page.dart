import 'package:flutter/material.dart';

import '../models/client_assignment.dart';
import '../models/sales_forecast.dart';
import '../models/sales_transaction.dart';
import '../models/user_role.dart';
import '../services/app_repositories.dart';
import '../services/app_session.dart';
import '../services/chart_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/brand_forecast_dialog.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/sales_forecast_charts.dart';
import '../widgets/sales_forecast_filter.dart';
import '../widgets/sales_forecast_table.dart';

/// The Sales Forecasting screen (sidebar index 4).
class SalesForecastingPage extends StatelessWidget {
  const SalesForecastingPage({super.key});

  bool get _viewOnly =>
      AppSession.instance.currentRole?.salesForecastingIsViewOnly ?? false;

  Future<void> _handleDelete(BuildContext context, BrandForecast item) async {
    final confirmed = await confirmDelete(context: context, itemLabel: item.brand);
    if (!confirmed) return;
    try {
      await AppRepositories.salesForecasts.delete(item.brand);
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: 4,
      body: StreamBuilder<List<BrandForecast>>(
        stream: AppRepositories.salesForecasts.watchAll(),
        builder: (context, forecastSnap) {
          return StreamBuilder<List<FeedEntryRecord>>(
            stream: AppRepositories.predictionAlerts.watchAll(),
            builder: (context, alertSnap) {
              return StreamBuilder<List<SalesTransaction>>(
                stream: AppRepositories.salesTransactions.watchAll(),
                builder: (context, txnSnap) {
                  final loading = forecastSnap.connectionState ==
                          ConnectionState.waiting ||
                      alertSnap.connectionState == ConnectionState.waiting ||
                      txnSnap.connectionState == ConnectionState.waiting;
                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final error = forecastSnap.error ?? alertSnap.error ?? txnSnap.error;
                  if (error != null) {
                    return Center(child: Text('Failed to load: $error'));
                  }

                  final forecasts = forecastSnap.data ?? const <BrandForecast>[];
                  final alerts = (alertSnap.data ?? const <FeedEntryRecord>[])
                      .map((e) => FeedEntry(
                            description: e.description,
                            timestamp: e.timestamp,
                          ))
                      .toList();
                  final transactions = txnSnap.data ?? const <SalesTransaction>[];

                  final months = lastNMonths(6);
                  final monthLabels = [for (final m in months) m.label];
                  final actualTotals = monthlySalesTotals(transactions, months);
                  final lastThree = actualTotals.length >= 3
                      ? actualTotals.sublist(actualTotals.length - 3)
                      : actualTotals;
                  final double projectedFlatValue = lastThree.isEmpty
                      ? 0
                      : lastThree.reduce((a, b) => a + b) / lastThree.length;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth >= 1000;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sales Forecasting',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilterAndSearchCard(
                              onGenerateForecast: (period, year, brand) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Generating $period forecast for $year — $brand',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildChartsRow(
                              isWide,
                              forecasts,
                              actualTotals,
                              monthLabels,
                              projectedFlatValue,
                            ),
                            const SizedBox(height: 20),
                            _buildBottomRow(context, isWide, forecasts, alerts),
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

  Widget _buildChartsRow(
    bool isWide,
    List<BrandForecast> forecasts,
    List<double> actualTotals,
    List<String> monthLabels,
    double projectedFlatValue,
  ) {
    final trend = SalesTrendChart(
      actualTotals: actualTotals,
      monthLabels: monthLabels,
      projectedFlatValue: projectedFlatValue,
    );
    final demand = ForecastedDemandChart(forecasts: forecasts);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: trend),
          const SizedBox(width: 16),
          Expanded(child: demand),
        ],
      );
    }
    return Column(
      children: [trend, const SizedBox(height: 16), demand],
    );
  }

  Widget _buildBottomRow(
    BuildContext context,
    bool isWide,
    List<BrandForecast> forecasts,
    List<FeedEntry> alerts,
  ) {
    final Widget table = TableCard(
      onViewAll: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing all brand forecasts')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_viewOnly)
            Align(
              alignment: Alignment.centerRight,
              child: AddEntityButton(
                label: 'Add Forecast',
                onPressed: () => showBrandForecastDialog(context),
              ),
            ),
          if (!_viewOnly) const SizedBox(height: 12),
          ForecastTable(
            items: forecasts,
            onEdit: _viewOnly
                ? null
                : (item) => showBrandForecastDialog(context, existing: item),
            onDelete: _viewOnly ? null : (item) => _handleDelete(context, item),
          ),
        ],
      ),
    );
    final Widget alertsCard = ActivityFeedCard(
      title: 'Prediction Alerts',
      entries: alerts,
      onViewAll: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viewing all prediction alerts')),
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: table),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: alertsCard),
        ],
      );
    }
    return Column(
      children: [table, const SizedBox(height: 16), alertsCard],
    );
  }
}
