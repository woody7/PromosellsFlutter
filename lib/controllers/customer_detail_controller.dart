import 'package:get/get.dart';

import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/services/customer_api.dart';

/// Port of customerstock.jsx's data-loading state for a single customer.
///
/// One deliberate improvement over the React version: there, the
/// drop-off/pickup/sales modals pass `onConfirm={() => {}}` — a no-op — so
/// the stock table doesn't refresh after a transaction (only AddIncident
/// refreshes anything, via handleIncidentAdded). Here, every transaction
/// modal calls [refresh] on success, so the screen reflects what was just
/// submitted without the user having to navigate away and back.
class CustomerDetailController extends GetxController {
  CustomerDetailController(this.customerId);

  final int customerId;

  final Rxn<Customer> customer = Rxn<Customer>();
  final RxList<CustomerStockItem> stocks = <CustomerStockItem>[].obs;
  final RxList<CustomerIncident> incidents = <CustomerIncident>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isIncidentsLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        CustomerApi.fetchCustomerDetails(customerId),
        CustomerApi.fetchCustomerStocks(customerId),
        CustomerApi.fetchCustomerIncidents(customerId),
      ]);
      customer.value = results[0] as Customer;
      stocks.value = results[1] as List<CustomerStockItem>;
      incidents.value = results[2] as List<CustomerIncident>;
    } on CustomerApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStocks() async {
    try {
      stocks.value = await CustomerApi.fetchCustomerStocks(customerId);
    } on CustomerApiException {
      // Keep showing the last known list rather than clearing it on a
      // transient refresh failure — the transaction itself already succeeded.
    }
  }

  Future<void> refreshIncidents() async {
    isIncidentsLoading.value = true;
    try {
      incidents.value = await CustomerApi.fetchCustomerIncidents(customerId);
    } on CustomerApiException {
      // Same reasoning as refreshStocks.
    } finally {
      isIncidentsLoading.value = false;
    }
  }

  Future<void> refreshAfterTransaction() async {
    await Future.wait([refreshStocks(), refreshIncidents()]);
  }
}
