import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:promosells_flutter/controllers/customer_map_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/views/customers/customer_detail_screen.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of CustomerMap.jsx — OpenStreetMap tiles via flutter_map, matching
/// the React app's react-leaflet + OSM setup (not Google Maps, see
/// ROADMAP.md's decisions log).
class CustomerMapScreen extends StatelessWidget {
  const CustomerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomerMapController>()) {
      Get.put(CustomerMapController());
    }
    final controller = Get.find<CustomerMapController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null) {
        return Center(child: MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error));
      }

      final located = controller.locatedCustomers;

      return Column(
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: located.isEmpty
                  ? MyText.bodyMedium('No customers have a saved location yet.', muted: true)
                  : MyText.bodySmall('Showing ${located.length} of ${controller.customers.length} customers with a saved location.',
                      muted: true),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: controller.mapCenter, initialZoom: controller.zoom),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.adroit.promosells_flutter',
                ),
                MarkerLayer(
                  markers: located
                      .map((customer) => Marker(
                            point: LatLng(customer.latitude!, customer.longitude!),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _showCustomerSheet(context, customer),
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showCustomerSheet(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: MySpacing.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleMedium(customer.contactPerson),
            MySpacing.height(4),
            MyText.bodyMedium(customer.companyName),
            MyText.bodyMedium(customer.address),
            MySpacing.height(16),
            MyButton.block(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: customer.customerId)),
                );
              },
              child: MyText.bodyMedium('View Details', color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
