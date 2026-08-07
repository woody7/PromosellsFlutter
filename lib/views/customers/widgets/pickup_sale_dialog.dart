import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/services/customer_api.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';
import 'package:promosells_flutter/widgets/numeric_stepper_field.dart';

const _incidentTypes = ['Visit', 'Telephone Call', 'Whatsapp', 'Email'];

enum PickupSaleMode { pickup, sale }

/// Port of PickupModal.js + SalesModal.js — near-identical forms, both
/// operating on the customer's currently-held stock (capped per item at
/// what they hold), differing only in title, icon, and endpoint. One
/// behavioral difference kept from the originals: PickupModal.js requires
/// an incident type before submitting, SalesModal.js doesn't.
Future<void> showPickupSaleDialog(
  BuildContext context, {
  required PickupSaleMode mode,
  required int customerId,
  required List<CustomerStockItem> stocks,
  required VoidCallback onSubmitted,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: _PickupSaleDialog(mode: mode, customerId: customerId, stocks: stocks, onSubmitted: onSubmitted),
      ),
    ),
  );
}

class _PickupSaleDialog extends StatefulWidget {
  const _PickupSaleDialog({required this.mode, required this.customerId, required this.stocks, required this.onSubmitted});

  final PickupSaleMode mode;
  final int customerId;
  final List<CustomerStockItem> stocks;
  final VoidCallback onSubmitted;

  @override
  State<_PickupSaleDialog> createState() => _PickupSaleDialogState();
}

class _PickupSaleDialogState extends State<_PickupSaleDialog> {
  final Map<int, int> _quantities = {};
  DateTime _incidentDate = DateTime.now();
  String _incidentType = '';
  final _incidentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  bool get _isPickup => widget.mode == PickupSaleMode.pickup;

  @override
  void dispose() {
    _incidentController.dispose();
    super.dispose();
  }

  bool get _isFormValid => _quantities.values.any((q) => q > 0);

  Future<void> _submit() async {
    if (!_isFormValid) {
      setState(() => _error = 'Please select at least one item with a quantity greater than 0.');
      return;
    }
    if (_isPickup && _incidentType.isEmpty) {
      setState(() => _error = 'Please select an incident type.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final email = Get.find<AuthController>().session.value?.email ?? '';
      final stockArray = _quantities.entries.where((e) => e.value > 0).map((e) => [e.key, e.value]).toList();
      if (_isPickup) {
        await CustomerApi.submitPickup(
          customerId: widget.customerId,
          stockArray: stockArray,
          incidentDate: _incidentDate,
          incidentType: _incidentType,
          incident: _incidentController.text,
          email: email,
        );
      } else {
        await CustomerApi.submitSale(
          customerId: widget.customerId,
          stockArray: stockArray,
          incidentDate: _incidentDate,
          incidentType: _incidentType,
          incident: _incidentController.text,
          email: email,
        );
      }
      widget.onSubmitted();
      if (mounted) Navigator.of(context).pop();
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
          child: MyText.titleMedium(_isPickup ? '🚚 Pick Up' : '🛒 Sale'),
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
                MyText.titleSmall('Stocks'),
                MySpacing.height(8),
                if (widget.stocks.isEmpty)
                  MyText.bodySmall('This customer has no stock on hand.', muted: true)
                else
                  ...widget.stocks.map((item) => Padding(
                        padding: MySpacing.vertical(4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: MyText.bodyMedium(item.description),
                            ),
                            Expanded(child: MyText.bodySmall('On hand: ${item.quantity.toStringAsFixed(0)}', muted: true)),
                            NumericStepperField(
                              value: _quantities[item.stockListId] ?? 0,
                              max: item.quantity.toInt(),
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
}
