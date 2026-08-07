import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/stocklist_controller.dart';
import 'package:promosells_flutter/views/reports/report_stub_screen.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of Modal.js's confirmation flow: review selected items + customer
/// details, confirm, then show a success state before navigating on.
Future<void> showDropOffConfirmation(BuildContext context, StocklistController controller) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DropOffConfirmationDialog(controller: controller),
  );
}

class _DropOffConfirmationDialog extends StatefulWidget {
  const _DropOffConfirmationDialog({required this.controller});

  final StocklistController controller;

  @override
  State<_DropOffConfirmationDialog> createState() => _DropOffConfirmationDialogState();
}

class _DropOffConfirmationDialogState extends State<_DropOffConfirmationDialog> {
  bool _submitted = false;

  Future<void> _confirm() async {
    final ok = await widget.controller.submit();
    if (!mounted) return;
    if (ok) {
      setState(() => _submitted = true);
    } else {
      setState(() {}); // re-render to show controller.submitError
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    if (_submitted) {
      final result = c.lastResult.value;
      return AlertDialog(
        title: MyText.titleMedium('Drop-Off Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.bodyMedium('Submitted successfully!', color: Colors.green),
            if (result?.hasStockMovement == true) ...[
              MySpacing.height(8),
              MyText.bodySmall('Document No: ${result!.documentNumber}', muted: true),
            ] else ...[
              MySpacing.height(8),
              MyText.bodySmall('No stock items were selected — recorded as a visit note only.', muted: true),
            ],
          ],
        ),
        actions: [
          MyButton(
            onPressed: () {
              final documentNumber = result?.documentNumber;
              c.resetForm();
              Navigator.of(context).pop();
              if (documentNumber != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReportStubScreen(documentNumber: documentNumber)),
                );
              }
            },
            child: MyText.bodyMedium('OK', color: Colors.white),
          ),
        ],
      );
    }

    return AlertDialog(
      title: MyText.titleMedium('Drop-Off Confirmation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.bodyMedium('Are you sure you want to drop off these items?'),
            MySpacing.height(12),
            MyText.titleSmall('Selected Items'),
            if (c.selectedItems.isEmpty)
              MyText.bodySmall('None', muted: true)
            else
              ...c.selectedItems.map((item) => MyText.bodySmall('${item.entry.description}: ${item.quantity}')),
            MySpacing.height(12),
            MyText.titleSmall('Customer Details'),
            MyText.bodySmall('Company Name: ${c.companyName.value}'),
            MyText.bodySmall('Telephone: ${c.tel.value}'),
            MyText.bodySmall('Contact Person: ${c.contactPerson.value}'),
            MyText.bodySmall('Address: ${c.address.value}'),
            MyText.bodySmall('Ref No: ${c.refNo.value}'),
            MyText.bodySmall('Office Photo: ${c.photo.value != null ? c.photo.value!.name : "None attached"}'),
            MyText.bodySmall(
              'Office Location: ${c.latitude.value != null && c.longitude.value != null ? '${c.latitude.value!.toStringAsFixed(5)}, ${c.longitude.value!.toStringAsFixed(5)}' : "Not captured"}',
            ),
            MyText.bodySmall(
              'Demo App Installed: ${c.demoAppInstalled.value == true ? "Yes" : c.demoAppInstalled.value == false ? "No" : "Not specified"}',
            ),
            if (c.submitError.value != null) ...[
              MySpacing.height(12),
              MyText.bodySmall(c.submitError.value!, color: Theme.of(context).colorScheme.error),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        Obx(() => MyButton(
              onPressed: c.isSubmitting.value ? null : _confirm,
              child: c.isSubmitting.value
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : MyText.bodyMedium('Confirm', color: Colors.white),
            )),
      ],
    );
  }
}
