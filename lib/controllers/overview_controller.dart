import 'package:get/get.dart';

import 'package:promosells_flutter/models/admin_dashboard.dart';
import 'package:promosells_flutter/services/admin_dashboard_api.dart';

/// Port of Overview.jsx's single fetchData() call.
class OverviewController extends GetxController {
  final Rxn<AdminDashboardData> data = Rxn<AdminDashboardData>();
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
      data.value = await AdminDashboardApi.fetchAll();
    } on AdminDashboardApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
