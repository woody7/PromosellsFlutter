import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/services/customer_api.dart';

/// Port of CustomerMap.jsx's data-loading and centering logic.
class CustomerMapController extends GetxController {
  static const defaultCenter = LatLng(7.9465, -1.0232); // Ghana, used when no customers have a saved location
  static const defaultZoom = 7.0;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final auth = Get.find<AuthController>();
      customers.value = await CustomerApi.fetchCustomers(
        isAdmin: auth.isAdmin,
        userEmail: auth.session.value?.email ?? '',
      );
    } on CustomerApiException {
      error.value = 'Unable to load customers.';
    } finally {
      isLoading.value = false;
    }
  }

  List<Customer> get locatedCustomers {
    return customers.where((c) => c.latitude != null && c.longitude != null && !(c.latitude == 0 && c.longitude == 0)).toList();
  }

  LatLng get mapCenter {
    final located = locatedCustomers;
    if (located.isEmpty) return defaultCenter;
    return LatLng(located.first.latitude!, located.first.longitude!);
  }

  double get zoom => locatedCustomers.isNotEmpty ? 12.0 : defaultZoom;
}
