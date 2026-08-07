import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/controllers/customer_detail_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/views/customers/widgets/add_incident_dialog.dart';
import 'package:promosells_flutter/views/customers/widgets/drop_off_existing_customer_dialog.dart';
import 'package:promosells_flutter/views/customers/widgets/pickup_sale_dialog.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of customerstock.jsx.
class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final int customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final String _tag = 'customer_${widget.customerId}';
  late final CustomerDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CustomerDetailController(widget.customerId), tag: _tag);
  }

  @override
  void dispose() {
    Get.delete<CustomerDetailController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MyText.titleMedium('Customer Details')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null) {
          return Center(child: MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error));
        }
        final customer = controller.customer.value;
        if (customer == null) {
          return Center(child: MyText.bodyMedium('Customer not found'));
        }

        return SingleChildScrollView(
          padding: MySpacing.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.headlineSmall(customer.companyName),
              MySpacing.height(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MyButton.small(
                    onPressed: () => showAddIncidentDialog(context, customerId: widget.customerId, onSubmitted: controller.refreshIncidents),
                    child: MyText.bodySmall('⚠ Add Incident', color: Colors.white),
                  ),
                  MyButton.small(
                    onPressed: () => showDropOffExistingCustomerDialog(
                      context,
                      customer: customer,
                      onSubmitted: controller.refreshAfterTransaction,
                    ),
                    child: MyText.bodySmall('⬇ Drop Off', color: Colors.white),
                  ),
                  MyButton.small(
                    onPressed: () => showPickupSaleDialog(
                      context,
                      mode: PickupSaleMode.pickup,
                      customerId: widget.customerId,
                      stocks: controller.stocks,
                      onSubmitted: controller.refreshAfterTransaction,
                    ),
                    child: MyText.bodySmall('⬆ Pick Up', color: Colors.white),
                  ),
                  MyButton.small(
                    onPressed: () => showPickupSaleDialog(
                      context,
                      mode: PickupSaleMode.sale,
                      customerId: widget.customerId,
                      stocks: controller.stocks,
                      onSubmitted: controller.refreshAfterTransaction,
                    ),
                    child: MyText.bodySmall('💰 Sales', color: Colors.white),
                  ),
                ],
              ),
              MySpacing.height(16),
              MyCard(
                paddingAll: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleSmall('Customer Details'),
                    MySpacing.height(8),
                    MyText.bodyMedium('Name: ${customer.contactPerson}'),
                    MyText.bodyMedium('Company: ${customer.companyName}'),
                    MyText.bodyMedium('Contact: ${customer.tel}'),
                    MyText.bodyMedium('Address: ${customer.address}'),
                    MyText.bodyMedium(
                      'Demo App Installed: ${customer.demoAppInstalled == true ? "Yes" : customer.demoAppInstalled == false ? "No" : "Unknown"}',
                    ),
                    if (customer.photoPath != null) ...[
                      MySpacing.height(8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network('${ApiConfig.baseUrl}${customer.photoPath}', width: 160, height: 160, fit: BoxFit.cover),
                      ),
                    ],
                  ],
                ),
              ),
              MySpacing.height(16),
              MyCard(
                paddingAll: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleSmall('Stock'),
                    MySpacing.height(8),
                    if (controller.stocks.isEmpty)
                      MyText.bodySmall('No stock data available for this customer.', muted: true)
                    else
                      _StockTable(items: controller.stocks),
                  ],
                ),
              ),
              MySpacing.height(16),
              MyCard(
                paddingAll: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleSmall('Customer Incidents History'),
                    MySpacing.height(8),
                    if (controller.isIncidentsLoading.value)
                      const Center(child: CircularProgressIndicator())
                    else if (controller.incidents.isEmpty)
                      MyText.bodySmall('No incidents found for this customer.', muted: true)
                    else
                      _IncidentsTable(incidents: controller.incidents),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StockTable extends StatelessWidget {
  const _StockTable({required this.items});

  final List<CustomerStockItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Qty'), numeric: true),
          DataColumn(label: Text('Elapsed Days'), numeric: true),
        ],
        rows: items
            .map((stock) => DataRow(cells: [
                  DataCell(Text(stock.code)),
                  DataCell(Text(stock.description)),
                  DataCell(Text(stock.quantity.toStringAsFixed(0))),
                  DataCell(Text('${stock.elapsedDays ?? '-'}')),
                ]))
            .toList(),
      ),
    );
  }
}

class _IncidentsTable extends StatelessWidget {
  const _IncidentsTable({required this.incidents});

  final List<CustomerIncident> incidents;

  @override
  Widget build(BuildContext context) {
    final sorted = [...incidents]..sort((a, b) {
        final dateA = a.date ?? DateTime(0);
        final dateB = b.date ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Incident')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Doc No.')),
          DataColumn(label: Text('User')),
        ],
        rows: sorted
            .map((incident) => DataRow(cells: [
                  DataCell(Text(incident.date != null
                      ? '${incident.date!.year}-${incident.date!.month.toString().padLeft(2, '0')}-${incident.date!.day.toString().padLeft(2, '0')}'
                      : '-')),
                  DataCell(Text(incident.incident.isEmpty ? '-' : incident.incident)),
                  DataCell(Text(incident.incidentType.isEmpty ? '-' : incident.incidentType)),
                  DataCell(Text(incident.documentNumber ?? '-')),
                  DataCell(Text(incident.createdBy ?? '-')),
                ]))
            .toList(),
      ),
    );
  }
}
