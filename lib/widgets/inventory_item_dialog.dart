import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../models/sales_transaction.dart';
import '../services/app_repositories.dart';
import 'dialog_widgets.dart';

Future<void> showInventoryItemDialog(
  BuildContext context, {
  InventoryItem? existing,
  String? nextItemId,
}) {
  return showFormDialog(
    context: context,
    title: existing == null ? 'Add Inventory Item' : 'Edit Inventory Item',
    child: _InventoryItemForm(existing: existing, nextItemId: nextItemId),
  );
}

class _InventoryItemForm extends StatefulWidget {
  final InventoryItem? existing;
  final String? nextItemId;

  const _InventoryItemForm({this.existing, this.nextItemId});

  @override
  State<_InventoryItemForm> createState() => _InventoryItemFormState();
}

class _InventoryItemFormState extends State<_InventoryItemForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brand;
  late final TextEditingController _category;
  late final TextEditingController _condition;
  late final TextEditingController _location;
  late final TextEditingController _dateAdded;
  late final TextEditingController _price;
  late InventoryStatus _status;
  late TransactionStatus _transactionStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _brand = TextEditingController(text: e?.brand ?? '');
    _category = TextEditingController(text: e?.category ?? '');
    _condition = TextEditingController(text: e?.condition ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _dateAdded = TextEditingController(
      text: e?.dateAdded ??
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
    );
    _price = TextEditingController(text: e?.price ?? '');
    _status = e?.status ?? InventoryStatus.available;
    _transactionStatus = e?.transactionStatus ?? TransactionStatus.none;
  }

  @override
  void dispose() {
    _brand.dispose();
    _category.dispose();
    _condition.dispose();
    _location.dispose();
    _dateAdded.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final item = InventoryItem(
      itemId: widget.existing?.itemId ?? widget.nextItemId ?? 'INV-NEW',
      brand: _brand.text.trim(),
      category: _category.text.trim(),
      condition: _condition.text.trim(),
      status: _status,
      location: _location.text.trim(),
      dateAdded: _dateAdded.text.trim(),
      transactionStatus: _transactionStatus,
      price: _price.text.trim(),
    );

    try {
      final bool justSold = _status == InventoryStatus.sold &&
          widget.existing?.status != InventoryStatus.sold;

      if (widget.existing == null) {
        await AppRepositories.inventory.add(item, id: item.itemId);
      } else {
        await AppRepositories.inventory.update(item.itemId, item);
      }

      // Log a sale the moment an item flips to Sold — this is what feeds
      // the Dashboard's Total Sales / Monthly Sales Growth cards. Doesn't
      // fire again on later edits since it only triggers on the
      // transition into Sold, not every save while already Sold.
      if (justSold) {
        await AppRepositories.salesTransactions.add(
          SalesTransaction(
            itemLabel: '${item.brand} ${item.category} (${item.itemId})',
            amount: _parsePriceToAmount(item.price),
            date: DateTime.now(),
            itemId: item.itemId,
          ),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Strips currency symbols/commas from a price string like "₱720,000"
  /// down to a plain number. Falls back to 0 if nothing parseable is found
  double _parsePriceToAmount(String price) {
    final digitsOnly = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digitsOnly) ?? 0;
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
          DialogTextField(label: 'Category', controller: _category, validator: _required),
          DialogTextField(label: 'Condition', controller: _condition, validator: _required),
          DialogDropdown<InventoryStatus>(
            label: 'Status',
            value: _status,
            options: InventoryStatus.values,
            labelBuilder: (s) => switch (s) {
              InventoryStatus.available => 'Available',
              InventoryStatus.reserved => 'Reserved',
              InventoryStatus.rejected => 'Rejected',
              InventoryStatus.sold => 'Sold',
            },
            onChanged: (v) => setState(() => _status = v),
          ),
          DialogTextField(label: 'Location', controller: _location, validator: _required),
          DialogTextField(label: 'Date Added', controller: _dateAdded, validator: _required),
          DialogDropdown<TransactionStatus>(
            label: 'Transaction Status',
            value: _transactionStatus,
            options: TransactionStatus.values,
            labelBuilder: (s) => switch (s) {
              TransactionStatus.none => 'None',
              TransactionStatus.pending => 'Pending',
              TransactionStatus.cancelled => 'Cancelled',
              TransactionStatus.completed => 'Completed',
            },
            onChanged: (v) => setState(() => _transactionStatus = v),
          ),
          DialogTextField(label: 'Price', controller: _price, validator: _required),
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
