import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/incident_report_controller.dart';
import 'package:promosells_flutter/models/incident_summary.dart';
import 'package:promosells_flutter/views/customers/customer_detail_screen.dart';
import 'package:promosells_flutter/views/reports/report_detail_screen.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of IncidentReportByDate.js.
class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<IncidentReportController>()) {
      Get.put(IncidentReportController());
    }
    final controller = Get.find<IncidentReportController>();

    return SingleChildScrollView(
      padding: MySpacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.headlineSmall('Incident Report by Date'),
          MyText.bodySmall('Generate and export incident reports based on date range and user', muted: true),
          MySpacing.height(16),
          MyCard(
            paddingAll: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleSmall('Filter Options'),
                MySpacing.height(12),
                Row(
                  children: [
                    Expanded(child: _DateField(label: 'Start Date', value: controller.startDate, controller: controller)),
                    MySpacing.width(12),
                    Expanded(child: _DateField(label: 'End Date', value: controller.endDate, controller: controller)),
                  ],
                ),
                MySpacing.height(12),
                Obx(() => controller.isAdmin
                    ? DropdownButtonFormField<String>(
                        initialValue: controller.selectedUserName.value,
                        decoration: const InputDecoration(labelText: 'User', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: 'All', child: Text('All Users')),
                          ...controller.users.map((u) => DropdownMenuItem(value: u.userName, child: Text(u.userName))),
                        ],
                        onChanged: (v) => controller.selectedUserName.value = v ?? 'All',
                      )
                    : TextFormField(
                        initialValue: controller.currentUserEmail,
                        enabled: false,
                        decoration: const InputDecoration(labelText: 'User', border: OutlineInputBorder()),
                      )),
                MySpacing.height(16),
                Obx(() => MyButton(
                      onPressed: controller.isLoading.value ? null : controller.search,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : MyText.bodyMedium('Generate Report', color: Colors.white),
                    )),
              ],
            ),
          ),
          Obx(() {
            final error = controller.error.value;
            if (error == null || error.isEmpty) return MySpacing.empty();
            return Padding(
              padding: MySpacing.top(12),
              child: MyText.bodyMedium(error, color: Theme.of(context).colorScheme.error),
            );
          }),
          Obx(() {
            if (controller.incidents.isEmpty) return MySpacing.empty();
            return Padding(
              padding: MySpacing.top(16),
              child: MyCard(
                paddingAll: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MyText.titleSmall('Results'),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: controller.isExporting.value ? null : controller.exportPdf,
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text('Export PDF'),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.isExporting.value ? null : controller.exportCsv,
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Export CSV'),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.copyAsText,
                          icon: Icon(controller.copied.value ? Icons.check : Icons.copy, size: 16),
                          label: Text(controller.copied.value ? 'Copied!' : 'Copy as Text'),
                        ),
                      ],
                    ),
                    MySpacing.height(12),
                    _IncidentTable(incidents: controller.incidents),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.controller});

  final String label;
  final Rxn<DateTime> value;
  final IncidentReportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => InputDecorator(
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value.value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) value.value = picked;
            },
            child: Text(value.value != null
                ? '${value.value!.year}-${value.value!.month.toString().padLeft(2, '0')}-${value.value!.day.toString().padLeft(2, '0')}'
                : 'Select a date'),
          ),
        ));
  }
}

class _IncidentTable extends StatelessWidget {
  const _IncidentTable({required this.incidents});

  final List<IncidentSummary> incidents;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Incident Type')),
          DataColumn(label: Text('Incident')),
          DataColumn(label: Text('Details')),
          DataColumn(label: Text('Document No')),
          DataColumn(label: Text('Created By')),
        ],
        rows: incidents.map((incident) => _buildRow(context, incident)).toList(),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, IncidentSummary incident) {
    const linkStyle = TextStyle(color: Colors.blue, decoration: TextDecoration.underline);

    return DataRow(cells: [
      DataCell(Text(incident.incidentDate != null
          ? '${incident.incidentDate!.year}-${incident.incidentDate!.month.toString().padLeft(2, '0')}-${incident.incidentDate!.day.toString().padLeft(2, '0')}'
          : 'N/A')),
      DataCell(
        incident.customerName != null
            ? Text(incident.customerName!, style: linkStyle)
            : const Text('N/A'),
        onTap: incident.customerName != null && incident.customerId != null
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: incident.customerId!)),
                )
            : null,
      ),
      DataCell(Text(incident.customerPhone ?? 'N/A')),
      DataCell(Text(incident.incidentType ?? 'N/A')),
      DataCell(Text(incident.incidentText ?? 'N/A')),
      DataCell(Text(incident.details ?? 'N/A')),
      DataCell(
        Text(incident.documentNo ?? 'N/A', style: linkStyle),
        onTap: () {
          if (incident.documentNo != null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: incident.documentNo!)));
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No Report Available'),
                content: const Text('No report available for this incident.'),
                actions: [
                  MyButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: MyText.bodyMedium('OK', color: Colors.white),
                  ),
                ],
              ),
            );
          }
        },
      ),
      DataCell(Text(incident.createdBy ?? 'N/A')),
    ]);
  }
}
