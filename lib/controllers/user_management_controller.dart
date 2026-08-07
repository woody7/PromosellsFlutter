import 'package:get/get.dart';

import 'package:promosells_flutter/models/app_user.dart';
import 'package:promosells_flutter/services/incident_report_api.dart';

/// Port of UserManagement.js. Admin-only gating is handled by AppShell's
/// nav-item gating (same as the React route's userRole check via
/// TopNavBar.js hiding the link).
class UserManagementController extends GetxController {
  final RxList<AppUser> users = <AppUser>[].obs;
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
      users.value = await IncidentReportApi.fetchUsers();
    } on IncidentReportApiException {
      error.value = 'Failed to fetch users';
    } finally {
      isLoading.value = false;
    }
  }
}
