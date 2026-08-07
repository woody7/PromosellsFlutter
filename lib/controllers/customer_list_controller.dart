import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/services/customer_api.dart';

enum CustomerSortOption { none, alphabetical, newest, oldest }

/// Port of customerlist.js's state: load (role-gated endpoint), filter by
/// name/company/tel/address, sort.
class CustomerListController extends GetxController {
  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxString filterText = ''.obs;
  final Rx<CustomerSortOption> sortOption = CustomerSortOption.none.obs;

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
    } on CustomerApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  List<Customer> get visibleCustomers {
    var list = customers.toList();

    final filter = filterText.value.trim().toLowerCase();
    if (filter.isNotEmpty) {
      list = list
          .where((c) =>
              c.contactPerson.toLowerCase().contains(filter) ||
              c.companyName.toLowerCase().contains(filter) ||
              c.tel.toLowerCase().contains(filter) ||
              c.address.toLowerCase().contains(filter))
          .toList();
    }

    switch (sortOption.value) {
      case CustomerSortOption.alphabetical:
        list.sort((a, b) => a.contactPerson.compareTo(b.contactPerson));
      case CustomerSortOption.newest:
        list.sort((a, b) => b.customerId.compareTo(a.customerId));
      case CustomerSortOption.oldest:
        list.sort((a, b) => a.customerId.compareTo(b.customerId));
      case CustomerSortOption.none:
        break;
    }

    return list;
  }
}
