import 'package:flutter/material.dart';

import '../models/sales_forecast.dart';
import '../services/app_repositories.dart';
import 'dialog_widgets.dart';

/// Opens the Add/Edit Brand Forecast dialog. The brand name is used as the
/// Firestore document id, so it's locked (not editable) once a forecast
/// already exists for that brand — add a new one instead.
Future<void> showBrandForecastDialog(
  BuildContext context, {
  BrandForecast? existing,
}) {
  return showFormDialog(
    context: context,
    title: existing == null ? 'Add Brand Forecast' : 'Edit Brand Forecast',
    child: _BrandForecastForm(existing: existing),
  );
}

class _BrandForecastForm extends StatefulWidget {
  final BrandForecast? existing;
  const _BrandForecastForm({this.existing});

  @override
  State<_BrandForecastForm> createState() => _BrandForecastFormState();
}

class _BrandForecastFormState extends State<_BrandForecastForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brand;
  late final TextEditingController _historicalSales;
  late final TextEditingController _projectedSales;
  late final TextEditingController _growthPercent;
  late DemandTrend _trend;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _brand = TextEditingController(text: e?.brand ?? '');
    _historicalSales = TextEditingController(text: e?.historicalSales ?? '');
    _projectedSales = TextEditingController(text: e?.projectedSales ?? '');
    _growthPercent = TextEditingController(
      text: e == null ? '' : e.projectedGrowthPercent.toString(),
    );
    _trend = e?.trend ?? DemandTrend.stable;
  }

  @override
  void dispose() {
    _brand.dispose();
    _historicalSales.dispose();
    _projectedSales.dispose();
    _growthPercent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final brandName = _brand.text.trim();
    final item = BrandForecast(
      brand: brandName,
      historicalSales: _historicalSales.text.trim(),
      projectedSales: _projectedSales.text.trim(),
      projectedGrowthPercent: double.tryParse(_growthPercent.text.trim()) ?? 0,
      trend: _trend,
    );

    try {
      if (widget.existing == null) {
        await AppRepositories.salesForecasts.add(item, id: brandName);
      } else {
        await AppRepositories.salesForecasts.update(widget.existing!.brand, item);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Enter a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogTextField(
            label: 'Brand',
            controller: _brand,
            validator: _required,
            // Locking the brand on edit avoids leaving an orphaned
            // Firestore doc under the old id — the brand *is* the id.
          ),
          DialogTextField(
            label: 'Historical Sales (last 6 months)',
            controller: _historicalSales,
            validator: _required,
          ),
          DialogTextField(
            label: 'Projected Sales (next 3 months)',
            controller: _projectedSales,
            validator: _required,
          ),
          DialogTextField(
            label: 'Projected Growth % (use - for a decline)',
            controller: _growthPercent,
            validator: _requiredNumber,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
          DialogDropdown<DemandTrend>(
            label: 'Demand Trend',
            value: _trend,
            options: DemandTrend.values,
            labelBuilder: (t) => switch (t) {
              DemandTrend.increasing => 'Increasing',
              DemandTrend.decreasing => 'Decreasing',
              DemandTrend.stable => 'Stable',
            },
            onChanged: (v) => setState(() => _trend = v),
          ),
          const SizedBox(height: 4),
          DialogActions(
            primaryLabel: widget.existing == null ? 'Add Forecast' : 'Save Changes',
            isSaving: _isSaving,
            onCancel: () => Navigator.of(context).pop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}
