import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/services/customer_api.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

const _incidentTypes = ['Visit', 'Telephone Call', 'Whatsapp', 'Email'];

/// Port of AddIncidentModal.js.
Future<void> showAddIncidentDialog(
  BuildContext context, {
  required int customerId,
  required VoidCallback onSubmitted,
}) {
  return showDialog(
    context: context,
    builder: (context) => _AddIncidentDialog(customerId: customerId, onSubmitted: onSubmitted),
  );
}

class _AddIncidentDialog extends StatefulWidget {
  const _AddIncidentDialog({required this.customerId, required this.onSubmitted});

  final int customerId;
  final VoidCallback onSubmitted;

  @override
  State<_AddIncidentDialog> createState() => _AddIncidentDialogState();
}

class _AddIncidentDialogState extends State<_AddIncidentDialog> {
  DateTime _incidentDate = DateTime.now();
  String _incidentType = '';
  final _incidentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _incidentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_incidentType.isEmpty) {
      setState(() => _error = 'Please select an incident type.');
      return;
    }
    if (_incidentController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter incident details.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final email = Get.find<AuthController>().session.value?.email ?? '';
      await CustomerApi.submitAddIncident(
        customerId: widget.customerId,
        validIncidentDate: _incidentDate,
        incidentType: _incidentType,
        incident: _incidentController.text.trim(),
        email: email,
      );
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
    return AlertDialog(
      title: MyText.titleMedium('📝 Add Incident'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                child: Text('${_incidentDate.year}-${_incidentDate.month.toString().padLeft(2, '0')}-${_incidentDate.day.toString().padLeft(2, '0')}'),
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
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Incident', hintText: 'Enter incident details…', border: OutlineInputBorder()),
            ),
            if (_error != null) ...[
              MySpacing.height(12),
              MyText.bodySmall(_error!, color: Theme.of(context).colorScheme.error),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        MyButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : MyText.bodyMedium('Add Incident', color: Colors.white),
        ),
      ],
    );
  }
}
