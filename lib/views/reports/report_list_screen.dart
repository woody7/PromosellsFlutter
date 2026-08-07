import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/controllers/report_list_controller.dart';
import 'package:promosells_flutter/models/transaction_report_row.dart';
import 'package:promosells_flutter/views/reports/report_detail_screen.dart';
import 'package:promosells_flutter/widgets/access_denied_view.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of ReportList.jsx.
class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isAdmin) {
      return const AccessDeniedView(message: 'You do not have permission to access this page. Admin access required.');
    }

    if (!Get.isRegistered<ReportListController>()) {
      Get.put(ReportListController());
    }
    final controller = Get.find<ReportListController>();

    return Column(
      children: [
        Padding(
          padding: MySpacing.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Filter by company name', isDense: true, border: OutlineInputBorder()),
                  onChanged: (v) => controller.filterText.value = v,
                ),
              ),
              MySpacing.width(8),
              Obx(() => DropdownButton<ReportSortOption>(
                    value: controller.sortOption.value,
                    items: const [
                      DropdownMenuItem(value: ReportSortOption.none, child: Text('Sort by')),
                      DropdownMenuItem(value: ReportSortOption.companyName, child: Text('Company Name')),
                      DropdownMenuItem(value: ReportSortOption.contactPerson, child: Text('Contact Person')),
                      DropdownMenuItem(value: ReportSortOption.transactionType, child: Text('Transaction Type')),
                      DropdownMenuItem(value: ReportSortOption.date, child: Text('Date')),
                    ],
                    onChanged: (v) => controller.sortOption.value = v ?? ReportSortOption.none,
                  )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error.value != null) {
              return Center(child: MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error));
            }
            final list = controller.visibleReports;
            if (list.isEmpty) {
              return Center(child: MyText.bodyMedium('No reports found', muted: true));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Report ID')),
                  DataColumn(label: Text('Company Name')),
                  DataColumn(label: Text('Contact Person')),
                  DataColumn(label: Text('Telephone')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Transaction')),
                  DataColumn(label: Text('Date')),
                ],
                rows: list.map((report) => _buildRow(context, report)).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  DataRow _buildRow(BuildContext context, TransactionReportRow report) {
    void openDetail() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: report.reportId)),
        );

    return DataRow(
      onSelectChanged: (_) => openDetail(),
      cells: [
        DataCell(Text(report.reportId, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline))),
        DataCell(Text(report.companyName)),
        DataCell(Text(report.contactPerson)),
        DataCell(Text(report.tel)),
        DataCell(Text(report.address)),
        DataCell(Text(report.transactionType)),
        DataCell(Text(report.date != null ? '${report.date!.year}-${report.date!.month.toString().padLeft(2, '0')}-${report.date!.day.toString().padLeft(2, '0')}' : '-')),
      ],
    );
  }
}
