import 'package:flutter/material.dart';

import '../models/client_assignment.dart';
import '../services/app_repositories.dart';
import 'dialog_widgets.dart';

// ============================================================================
// CLIENT INQUIRY dialog
// ============================================================================

/// Opens the Add/Edit Client Inquiry dialog. Pass [existing] to edit a row
/// in place. [nextNo] (add mode only) is the next sequential "No." value,
/// computed by the caller from the current list. [initialClientType] lets
/// the two Quick Action buttons ("Add Walk In Client" / "Add Online
/// Inquiry") pre-fill a sensible starting value.
Future<void> showClientInquiryDialog(
  BuildContext context, {
  ClientInquiry? existing,
  int? nextNo,
  String? initialClientType,
}) {
  return showFormDialog(
    context: context,
    title: existing == null ? 'Add Client Inquiry' : 'Edit Client Inquiry',
    child: _ClientInquiryForm(
      existing: existing,
      nextNo: nextNo,
      initialClientType: initialClientType,
    ),
  );
}

class _ClientInquiryForm extends StatefulWidget {
  final ClientInquiry? existing;
  final int? nextNo;
  final String? initialClientType;

  const _ClientInquiryForm({this.existing, this.nextNo, this.initialClientType});

  @override
  State<_ClientInquiryForm> createState() => _ClientInquiryFormState();
}

class _ClientInquiryFormState extends State<_ClientInquiryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientName;
  late final TextEditingController _clientType;
  late final TextEditingController _clientRole;
  late final TextEditingController _inquirySource;
  late InquiryStatus _inquiryStatus;
  late TransactionResult _transactionResult;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _clientName = TextEditingController(text: e?.clientName ?? '');
    _clientType = TextEditingController(text: e?.clientType ?? widget.initialClientType ?? 'Walk-in');
    _clientRole = TextEditingController(text: e?.clientRole ?? 'Buyer');
    _inquirySource = TextEditingController(text: e?.inquirySource ?? '');
    _inquiryStatus = e?.inquiryStatus ?? InquiryStatus.newInquiry;
    _transactionResult = e?.transactionResult ?? TransactionResult.none;
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientType.dispose();
    _clientRole.dispose();
    _inquirySource.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final item = ClientInquiry(
      id: widget.existing?.id ?? '',
      no: widget.existing?.no ?? widget.nextNo ?? 1,
      clientName: _clientName.text.trim(),
      clientType: _clientType.text.trim(),
      clientRole: _clientRole.text.trim(),
      inquiryStatus: _inquiryStatus,
      inquirySource: _inquirySource.text.trim(),
      transactionResult: _transactionResult,
    );

    try {
      if (widget.existing == null) {
        await AppRepositories.clientInquiries.add(item);
      } else {
        await AppRepositories.clientInquiries.update(widget.existing!.id, item);
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
          DialogTextField(label: 'Client Name', controller: _clientName, validator: _required),
          DialogTextField(
            label: 'Client Type (e.g. Walk-in, VIP)',
            controller: _clientType,
            validator: _required,
          ),
          DialogTextField(
            label: 'Client Role (e.g. Buyer, Consignor)',
            controller: _clientRole,
            validator: _required,
          ),
          DialogDropdown<InquiryStatus>(
            label: 'Inquiry Status',
            value: _inquiryStatus,
            options: InquiryStatus.values,
            labelBuilder: (s) => switch (s) {
              InquiryStatus.newInquiry => 'New',
              InquiryStatus.closed => 'Closed',
              InquiryStatus.followedUp => 'Followed-up',
              InquiryStatus.reserved => 'Reserved',
            },
            onChanged: (v) => setState(() => _inquiryStatus = v),
          ),
          DialogTextField(
            label: 'Inquiry Source (e.g. Facebook, Tiktok, Instagram)',
            controller: _inquirySource,
            validator: _required,
          ),
          DialogDropdown<TransactionResult>(
            label: 'Transaction Result',
            value: _transactionResult,
            options: TransactionResult.values,
            labelBuilder: (s) => switch (s) {
              TransactionResult.none => 'None',
              TransactionResult.noPurchase => 'No Purchase',
              TransactionResult.purchased => 'Purchased',
            },
            onChanged: (v) => setState(() => _transactionResult = v),
          ),
          const SizedBox(height: 4),
          DialogActions(
            primaryLabel: widget.existing == null ? 'Add Inquiry' : 'Save Changes',
            isSaving: _isSaving,
            onCancel: () => Navigator.of(context).pop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SALES ASSOCIATE dialog
// ============================================================================

Future<void> showSalesAssociateDialog(
  BuildContext context, {
  SalesAssociateAssignment? existing,
}) {
  return showFormDialog(
    context: context,
    title: existing == null ? 'Add Sales Associate' : 'Edit Sales Associate',
    child: _SalesAssociateForm(existing: existing),
  );
}

class _SalesAssociateForm extends StatefulWidget {
  final SalesAssociateAssignment? existing;
  const _SalesAssociateForm({this.existing});

  @override
  State<_SalesAssociateForm> createState() => _SalesAssociateFormState();
}

class _SalesAssociateFormState extends State<_SalesAssociateForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _associateName;
  late final TextEditingController _currentClient;
  late AssociateStatus _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _associateName = TextEditingController(text: e?.associateName ?? '');
    _currentClient = TextEditingController(text: e?.currentClient == '-' ? '' : (e?.currentClient ?? ''));
    _status = e?.status ?? AssociateStatus.available;
  }

  @override
  void dispose() {
    _associateName.dispose();
    _currentClient.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final client = _currentClient.text.trim();
    final item = SalesAssociateAssignment(
      id: widget.existing?.id ?? '',
      associateName: _associateName.text.trim(),
      status: _status,
      currentClient: client.isEmpty ? '-' : client,
    );

    try {
      if (widget.existing == null) {
        await AppRepositories.salesAssociates.add(item);
      } else {
        await AppRepositories.salesAssociates.update(widget.existing!.id, item);
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
          DialogTextField(label: 'Associate Name', controller: _associateName, validator: _required),
          DialogDropdown<AssociateStatus>(
            label: 'Status',
            value: _status,
            options: AssociateStatus.values,
            labelBuilder: (s) => s == AssociateStatus.assigned ? 'Assigned' : 'Available',
            onChanged: (v) => setState(() => _status = v),
          ),
          DialogTextField(
            label: 'Current Client (leave blank if none)',
            controller: _currentClient,
          ),
          const SizedBox(height: 4),
          DialogActions(
            primaryLabel: widget.existing == null ? 'Add Associate' : 'Save Changes',
            isSaving: _isSaving,
            onCancel: () => Navigator.of(context).pop(),
            onPrimary: _save,
          ),
        ],
      ),
    );
  }
}
