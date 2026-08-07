import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/report_detail_controller.dart';
import 'package:promosells_flutter/models/transaction_report_row.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of Reportcomponents/Report.js.
class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late final String _tag = 'report_${widget.reportId}';
  late final ReportDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReportDetailController(widget.reportId), tag: _tag);
  }

  @override
  void dispose() {
    Get.delete<ReportDetailController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MyText.titleMedium(reportKindLabel(controller.kind))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(child: MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error));
        }
        if (controller.lines.isEmpty) {
          return Center(child: MyText.bodyMedium('No report details available.', muted: true));
        }

        final header = controller.lines.first;
        final isPickup = controller.kind == ReportKind.pickup;

        return SingleChildScrollView(
          padding: MySpacing.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.isExporting.value ? null : controller.downloadOrSharePdf,
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Download'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.isExporting.value ? null : controller.printPdf,
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.isExporting.value ? null : controller.shareExcel,
                    icon: const Icon(Icons.table_chart, size: 16),
                    label: const Text('Export Excel'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.isExporting.value ? null : controller.downloadOrSharePdf,
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                  ),
                ],
              ),
              MySpacing.height(16),
              MyCard(
                paddingAll: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 6, height: 44, color: Theme.of(context).colorScheme.primary),
                        MySpacing.width(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.headlineSmall(reportKindLabel(controller.kind)),
                            MyText.bodySmall('Promosells', muted: true),
                          ],
                        ),
                      ],
                    ),
                    MySpacing.height(24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.titleMedium(header.contactPerson),
                              MyText.bodySmall(header.address, muted: true),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MyText.titleMedium(header.companyName),
                              MySpacing.height(8),
                              MyText.bodySmall('Telephone Number: ${header.tel}'),
                              MyText.bodySmall('Report ID: ${header.reportId}'),
                              MyText.bodySmall('Date: ${_formatDate(header.date)}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    MySpacing.height(20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Samples')),
                          DataColumn(label: Text('Transaction')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Amt')),
                        ],
                        rows: [
                          for (var i = 0; i < controller.lines.length; i++)
                            DataRow(cells: [
                              DataCell(Text('${i + 1}')),
                              DataCell(Text(controller.lines[i].itemName ?? '')),
                              DataCell(Text(controller.lines[i].transactionType)),
                              DataCell(Text('${isPickup ? controller.lines[i].pickupQuantity : controller.lines[i].dropOffQuantity ?? ''}')),
                              DataCell(Text('${controller.lines[i].price ?? ''}')),
                              DataCell(Text('${controller.lines[i].amount ?? ''}')),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.kind == ReportKind.dropOff) ...[
                MySpacing.height(16),
                MyCard(
                  paddingAll: 12,
                  color: Colors.amber.shade100,
                  child: Center(child: MyText.bodyMedium('Please Note: This is not an Invoice')),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
