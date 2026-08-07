import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/models/stock_list_entry.dart';
import 'package:promosells_flutter/services/customer_api.dart';
import 'package:promosells_flutter/services/stocklist_api.dart';
import 'package:promosells_flutter/views/reports/report_detail_screen.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';
import 'package:promosells_flutter/widgets/numeric_stepper_field.dart';
import 'package:promosells_flutter/widgets/office_capture_fields.dart';

const _incidentTypes = ['Visit', 'Telephone Call', 'Whatsapp', 'Email'];

/// Port of Pages/DropOffModal.js — drop-off against an existing customer.
Future<void> showDropOffExistingCustomerDialog(
  BuildContext context, {
  required Customer customer,
  required VoidCallback onSubmitted,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: _DropOffExistingCustomerDialog(customer: customer, onSubmitted: onSubmitted),
      ),
    ),
  );
}

class _DropOffExistingCustomerDialog extends StatefulWidget {
  const _DropOffExistingCustomerDialog({required this.customer, required this.onSubmitted});

  final Customer customer;
  final VoidCallback onSubmitted;

  @override
  State<_DropOffExistingCustomerDialog> createState() => _DropOffExistingCustomerDialogState();
}

class _DropOffExistingCustomerDialogState extends State<_DropOffExistingCustomerDialog> {
  List<StockListEntry> _stock = [];
  bool _isLoadingStock = true;
  String? _loadError;

  final Map<int, int> _quantities = {};

  DateTime _incidentDate = DateTime.now();
  String _incidentType = '';
  final _incidentController = TextEditingController();

  XFile? _photo;
  double? _latitude;
  double? _longitude;
  bool? _demoAppInstalled;

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _demoAppInstalled = widget.customer.demoAppInstalled;
    _loadStock();
  }

  @override
  void dispose() {
    _incidentController.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    setState(() => _isLoadingStock = true);
    try {
      _stock = await StocklistApi.fetchAll();
      _loadError = null;
    } on StocklistApiException catch (e) {
      _loadError = e.message;
    } finally {
      if (mounted) setState(() => _isLoadingStock = false);
    }
  }

  bool get _isFormValid => _quantities.values.any((q) => q > 0);

  Future<void> _submit() async {
    if (!_isFormValid) {
      setState(() => _error = 'Please select at least one item with a quantity greater than 0.');
      return;
    }
    if (_incidentType.isEmpty) {
      setState(() => _error = 'Please select an incident type.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final email = Get.find<AuthController>().session.value?.email ?? '';
      final stockData = _quantities.entries.where((e) => e.value > 0).map((e) => [e.key, e.value]).toList();
      final result = await CustomerApi.submitDropOffExistingCustomer(
        customerId: widget.customer.customerId,
        incidentDate: _incidentDate,
        incidentType: _incidentType,
        incident: _incidentController.text,
        email: email,
        stockData: stockData,
        latitude: _latitude,
        longitude: _longitude,
        demoAppInstalled: _demoAppInstalled,
        photo: _photo,
      );
      widget.onSubmitted();
      if (mounted) {
        Navigator.of(context).pop();
        final documentNumber = result.documentNumber;
        if (documentNumber != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: documentNumber)));
        }
      }
    } on CustomerApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: MySpacing.all(16),
          child: MyText.titleMedium('📦 Drop Off'),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: MySpacing.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _incidentDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _incidentDate = picked);
                    },
                    child: Text(
                        '${_incidentDate.year}-${_incidentDate.month.toString().padLeft(2, '0')}-${_incidentDate.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                MySpacing.height(12),
                DropdownButtonFormField<String>(
                  initialValue: _incidentType.isEmpty ? null : _incidentType,
                  decoration: const InputDecoration(labelText: 'Incident Type', border: OutlineInputBorder()),
                  items: _incidentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _incidentType = v ?? ''),
                ),
                MySpacing.height(12),
                TextField(
                  controller: _incidentController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Incident', border: OutlineInputBorder()),
                ),
                MySpacing.height(16),
                OfficeCaptureFields(
                  demoAppInstalled: _demoAppInstalled,
                  onDemoAppInstalledChange: (v) => setState(() => _demoAppInstalled = v),
                  onPhotoSelected: (file) => setState(() => _photo = file),
                  onLocationCaptured: (lat, lng) => setState(() {
                    _latitude = lat;
                    _longitude = lng;
                  }),
                  existingPhotoUrl: widget.customer.photoPath != null ? '${ApiConfig.baseUrl}${widget.customer.photoPath}' : null,
                  existingLatitude: widget.customer.latitude,
                  existingLongitude: widget.customer.longitude,
                ),
                MySpacing.height(16),
                MyText.titleSmall('Select Items'),
                MySpacing.height(8),
                if (_isLoadingStock)
                  const Center(child: CircularProgressIndicator())
                else if (_loadError != null)
                  MyText.bodySmall(_loadError!, color: Theme.of(context).colorScheme.error)
                else
                  ..._groupStock(_stock).entries.map((group) => ExpansionTile(
                        title: MyText.bodyMedium(group.key, fontWeight: 600),
                        tilePadding: EdgeInsets.zero,
                        children: group.value
                            .map((item) => Padding(
                                  padding: MySpacing.vertical(4),
                                  child: Row(
                                    children: [
                                      Expanded(child: MyText.bodyMedium(item.description)),
                                      NumericStepperField(
                                        value: _quantities[item.stockListId] ?? 0,
                                        onValueChange: (qty) => setState(() {
                                          if (qty <= 0) {
                                            _quantities.remove(item.stockListId);
                                          } else {
                                            _quantities[item.stockListId] = qty;
                                          }
                                        }),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      )),
                if (_error != null) ...[
                  MySpacing.height(12),
                  MyText.bodySmall(_error!, color: Theme.of(context).colorScheme.error),
                ],
                MySpacing.height(16),
              ],
            ),
          ),
        ),
        Padding(
          padding: MySpacing.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
              MySpacing.width(8),
              MyButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : MyText.bodyMedium('Confirm', color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, List<StockListEntry>> _groupStock(List<StockListEntry> entries) {
    final grouped = <String, List<StockListEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.stockGroup, () => []).add(entry);
    }
    return grouped;
  }
}
