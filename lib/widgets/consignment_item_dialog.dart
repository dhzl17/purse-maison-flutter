import 'package:flutter/material.dart';

import '../models/consignment_item.dart';
import '../services/app_repositories.dart';
import 'dialog_widgets.dart';

Future<void> showConsignmentItemDialog(
  BuildContext context, {
  ConsignmentItem? existing,
  String? nextItemId,
}) {
  return showFormDialog(
    context: context,
    title: existing == null ? 'Add Consignment Item' : 'Edit Consignment Item',
    child: _ConsignmentItemForm(existing: existing, nextItemId: nextItemId),
  );
}

class _ConsignmentItemForm extends StatefulWidget {
  final ConsignmentItem? existing;
  final String? nextItemId;

  const _ConsignmentItemForm({this.existing, this.nextItemId});

  @override
  State<_ConsignmentItemForm> createState() => _ConsignmentItemFormState();
}

class _ConsignmentItemFormState extends State<_ConsignmentItemForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brand;
  late final TextEditingController _itemName;
  late final TextEditingController _category;
  late final TextEditingController _condition;
  late final TextEditingController _status;
  late final TextEditingController _price;
  late AuthenticationStatus _authentication;
  late PayoutStatus _payoutStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _brand = TextEditingController(text: e?.brand ?? '');
    _itemName = TextEditingController(text: e?.itemName ?? '');
    _category = TextEditingController(text: e?.category ?? '');
    _condition = TextEditingController(text: e?.condition ?? '');
    _status = TextEditingController(text: e?.status ?? 'Received');
    _price = TextEditingController(text: e?.price ?? '');
    _authentication = e?.authentication ?? AuthenticationStatus.verified;
    _payoutStatus = e?.payoutStatus ?? PayoutStatus.notYetSold;
  }

  @override
  void dispose() {
    _brand.dispose();
    _itemName.dispose();
    _category.dispose();
    _condition.dispose();
    _status.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final item = ConsignmentItem(
      itemId: widget.existing?.itemId ?? widget.nextItemId ?? 'NEW',
      brand: _brand.text.trim(),
      itemName: _itemName.text.trim(),
      // No image-upload flow yet — new items fall back to the same
      // "not found" placeholder the table already handles gracefully.
      imagePath: widget.existing?.imagePath ?? 'assets/images/placeholder.png',
      category: _category.text.trim(),
      condition: _condition.text.trim(),
      authentication: _authentication,
      status: _status.text.trim(),
      price: _price.text.trim(),
      payoutStatus: _payoutStatus,
    );

    try {
      if (widget.existing == null) {
        await AppRepositories.consignments.add(item, id: item.itemId);
      } else {
        await AppRepositories.consignments.update(item.itemId, item);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogTextField(label: 'Brand', controller: _brand, validator: _required),
          DialogTextField(label: 'Item Name', controller: _itemName, validator: _required),
          DialogTextField(label: 'Category', controller: _category, validator: _required),
          DialogTextField(label: 'Condition', controller: _condition, validator: _required),
          DialogDropdown<AuthenticationStatus>(
            label: 'Authentication',
            value: _authentication,
            options: AuthenticationStatus.values,
            labelBuilder: (s) => s == AuthenticationStatus.verified ? 'Verified' : 'Rejected',
            onChanged: (v) => setState(() => _authentication = v),
          ),
          DialogTextField(
            label: 'Status (e.g. Received, For Photography)',
            controller: _status,
            validator: _required,
          ),
          DialogTextField(label: 'Price', controller: _price, validator: _required),
          DialogDropdown<PayoutStatus>(
            label: 'Payout Status',
            value: _payoutStatus,
            options: PayoutStatus.values,
            labelBuilder: (s) => switch (s) {
              PayoutStatus.notYetSold => 'Not Yet Sold',
              PayoutStatus.sold => 'Sold',
              PayoutStatus.cancelled => 'Cancelled',
            },
            onChanged: (v) => setState(() => _payoutStatus = v),
          ),
          const SizedBox(height: 4),
          DialogActions(
            primaryLabel: widget.existing == null ? 'Add Item' : 'Save Changes',
            isSaving: _isSaving,
            onCancel: () => Navigator.of(context).pop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}
