import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/stocklist_controller.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';
import 'package:promosells_flutter/widgets/office_capture_fields.dart';

const _dropOffTypes = {'sample': 'Sample Drop-Off', 'return': 'Sales or Return'};
const _incidentTypes = ['Visit', 'Telephone Call', 'Whatsapp', 'Email'];

/// Port of Customerdetails.js for the new-customer drop-off flow (Stage 1) —
/// incident history + `customerId` aren't relevant here since the customer
/// doesn't exist yet (that part of Customerdetails.js only applies once
/// there's a real customerId, which comes with Stage 2's existing-customer flow).
class CustomerDetailsForm extends StatefulWidget {
  const CustomerDetailsForm({super.key, required this.controller});

  final StocklistController controller;

  @override
  State<CustomerDetailsForm> createState() => _CustomerDetailsFormState();
}

class _CustomerDetailsFormState extends State<CustomerDetailsForm> {
  late final TextEditingController _companyName;
  late final TextEditingController _contactPerson;
  late final TextEditingController _tel;
  late final TextEditingController _refNo;
  late final TextEditingController _incident;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _companyName = TextEditingController(text: c.companyName.value);
    _contactPerson = TextEditingController(text: c.contactPerson.value);
    _tel = TextEditingController(text: c.tel.value);
    _refNo = TextEditingController(text: c.refNo.value);
    _incident = TextEditingController(text: c.incident.value);
    _address = TextEditingController(text: c.address.value);
  }

  @override
  void dispose() {
    _companyName.dispose();
    _contactPerson.dispose();
    _tel.dispose();
    _refNo.dispose();
    _incident.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return MyCard(
      paddingAll: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium('Customer Details'),
          MySpacing.height(16),
          TextField(
            controller: _companyName,
            decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
            onChanged: (v) => c.companyName.value = v,
          ),
          MySpacing.height(12),
          TextField(
            controller: _contactPerson,
            decoration: const InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder()),
            onChanged: (v) => c.contactPerson.value = v,
          ),
          MySpacing.height(12),
          Obx(() => TextField(
                controller: _tel,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telephone Number',
                  border: const OutlineInputBorder(),
                  errorText: c.isPhoneValid.value ? null : 'Please enter a valid phone number.',
                ),
                onChanged: c.onTelChanged,
              )),
          MySpacing.height(12),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: c.dropOffType.value.isEmpty ? null : c.dropOffType.value,
                decoration: const InputDecoration(labelText: 'Drop-Off Type', border: OutlineInputBorder()),
                items: _dropOffTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => c.dropOffType.value = v ?? '',
              )),
          MySpacing.height(12),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: c.incidentType.value.isEmpty ? null : c.incidentType.value,
                decoration: const InputDecoration(labelText: 'Incident Type', border: OutlineInputBorder()),
                items: _incidentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => c.incidentType.value = v ?? '',
              )),
          MySpacing.height(12),
          Obx(() => InputDecorator(
                decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: c.date.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) c.date.value = picked;
                  },
                  child: Text('${c.date.value.year}-${c.date.value.month.toString().padLeft(2, '0')}-${c.date.value.day.toString().padLeft(2, '0')}'),
                ),
              )),
          MySpacing.height(12),
          TextField(
            controller: _refNo,
            decoration: const InputDecoration(labelText: 'Ref. No', border: OutlineInputBorder()),
            onChanged: (v) => c.refNo.value = v,
          ),
          MySpacing.height(12),
          TextField(
            controller: _incident,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Incident', border: OutlineInputBorder()),
            onChanged: (v) => c.incident.value = v,
          ),
          MySpacing.height(12),
          TextField(
            controller: _address,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
            onChanged: (v) => c.address.value = v,
          ),
          MySpacing.height(16),
          Obx(() => OfficeCaptureFields(
                demoAppInstalled: c.demoAppInstalled.value,
                onDemoAppInstalledChange: (v) => c.demoAppInstalled.value = v,
                onPhotoSelected: (file) => c.photo.value = file,
                onLocationCaptured: (lat, lng) {
                  c.latitude.value = lat;
                  c.longitude.value = lng;
                },
              )),
        ],
      ),
    );
  }
}
