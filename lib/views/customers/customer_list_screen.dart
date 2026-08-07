import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:promosells_flutter/controllers/customer_list_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/views/customers/customer_detail_screen.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of customerlist.js.
class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomerListController>()) {
      Get.put(CustomerListController());
    }
    final controller = Get.find<CustomerListController>();

    return Column(
      children: [
        Padding(
          padding: MySpacing.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Filter by name, company, contact, or address',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => controller.filterText.value = v,
                ),
              ),
              MySpacing.width(8),
              Obx(() => DropdownButton<CustomerSortOption>(
                    value: controller.sortOption.value,
                    items: const [
                      DropdownMenuItem(value: CustomerSortOption.none, child: Text('Sort by')),
                      DropdownMenuItem(value: CustomerSortOption.alphabetical, child: Text('A–Z')),
                      DropdownMenuItem(value: CustomerSortOption.newest, child: Text('Newest')),
                      DropdownMenuItem(value: CustomerSortOption.oldest, child: Text('Oldest')),
                    ],
                    onChanged: (v) => controller.sortOption.value = v ?? CustomerSortOption.none,
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
            final list = controller.visibleCustomers;
            if (list.isEmpty) {
              return Center(child: MyText.bodyMedium('No customers found', muted: true));
            }
            return ListView.builder(
              padding: MySpacing.only(left: 16, right: 16, bottom: 16),
              itemCount: list.length,
              itemBuilder: (context, index) => _CustomerCard(customer: list[index]),
            );
          }),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MySpacing.bottom(12),
      child: MyCard(
        paddingAll: 16,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: customer.customerId)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleSmall(customer.contactPerson),
            MySpacing.height(4),
            MyText.bodySmall('Company: ${customer.companyName}'),
            Row(
              children: [
                MyText.bodySmall('Contact: '),
                if (customer.tel.isNotEmpty)
                  InkWell(
                    onTap: () => launchUrl(Uri.parse('tel:${customer.tel}')),
                    child: MyText.bodySmall(customer.tel, color: Colors.blue, decoration: TextDecoration.underline),
                  )
                else
                  MyText.bodySmall('N/A'),
              ],
            ),
            MyText.bodySmall('Address: ${customer.address}'),
            MySpacing.height(8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: customer.customerId)),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
