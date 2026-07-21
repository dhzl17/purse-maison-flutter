import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common_widgets.dart';

/// The "Filter and Search" card: Period / Year / Brand dropdowns plus a
/// "Generate Forecast" button. Keeps its own filter selections internally —
/// the dummy chart/table data below it doesn't depend on these yet, so
/// there's nothing else for the page itself to track.
class FilterAndSearchCard extends StatefulWidget {
  final void Function(String period, String year, String brand)
  onGenerateForecast;

  const FilterAndSearchCard({super.key, required this.onGenerateForecast});

  @override
  State<FilterAndSearchCard> createState() => _FilterAndSearchCardState();
}

class _FilterAndSearchCardState extends State<FilterAndSearchCard> {
  String _period = 'Monthly';
  String _year = '2024';
  String _brand = 'All Brands';

  static const List<String> _periods = ['Monthly', 'Quarterly', 'Yearly'];
  static const List<String> _years = ['2022', '2023', '2024', '2025'];
  static const List<String> _brands = [
    'All Brands',
    'Louis Vuitton',
    'Chanel',
    'Dior',
    'Gucci',
    'Prada',
    'YSL',
    'Hermès',
  ];

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter and Search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 800;

              final Widget periodDropdown = SizedBox(
                width: isWide ? 220 : double.infinity,
                child: LabeledDropdown(
                  label: 'Select Period',
                  value: _period,
                  options: _periods,
                  onChanged: (v) => setState(() => _period = v!),
                ),
              );
              final Widget yearDropdown = SizedBox(
                width: isWide ? 220 : double.infinity,
                child: LabeledDropdown(
                  label: 'Select Year',
                  value: _year,
                  options: _years,
                  onChanged: (v) => setState(() => _year = v!),
                ),
              );
              final Widget brandDropdown = SizedBox(
                width: isWide ? 260 : double.infinity,
                child: LabeledDropdown(
                  label: 'Filter by Brand',
                  value: _brand,
                  options: _brands,
                  onChanged: (v) => setState(() => _brand = v!),
                ),
              );
              final Widget generateButton = NavyActionButton(
                label: '+ Generate Forecast',
                fullWidth: !isWide,
                onPressed: () =>
                    widget.onGenerateForecast(_period, _year, _brand),
              );

              if (isWide) {
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 14,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 14,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [periodDropdown, yearDropdown, brandDropdown],
                    ),
                    generateButton,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  periodDropdown,
                  const SizedBox(height: 14),
                  yearDropdown,
                  const SizedBox(height: 14),
                  brandDropdown,
                  const SizedBox(height: 16),
                  generateButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
