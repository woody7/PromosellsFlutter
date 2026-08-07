import 'package:get/get.dart';

import 'package:promosells_flutter/models/transaction_report_row.dart';
import 'package:promosells_flutter/services/report_api.dart';

enum ReportSortOption { none, companyName, contactPerson, transactionType, date }

/// Port of ReportList.jsx's state (the Admin-only gate itself is handled by
/// AppShell's nav-item gating, same as TopNavBar.js hiding the link).
class ReportListController extends GetxController {
  final RxList<TransactionReportRow> reports = <TransactionReportRow>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxString filterText = ''.obs;
  final Rx<ReportSortOption> sortOption = ReportSortOption.none.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await ReportApi.fetchAllReports();
      list.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
      reports.value = list;
    } on ReportApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionReportRow> get visibleReports {
    var list = reports.toList();

    final filter = filterText.value.trim().toLowerCase();
    if (filter.isNotEmpty) {
      list = list.where((r) => r.companyName.toLowerCase().contains(filter)).toList();
    }

    switch (sortOption.value) {
      case ReportSortOption.companyName:
        list.sort((a, b) => a.companyName.compareTo(b.companyName));
      case ReportSortOption.contactPerson:
        list.sort((a, b) => a.contactPerson.compareTo(b.contactPerson));
      case ReportSortOption.transactionType:
        list.sort((a, b) => a.transactionType.compareTo(b.transactionType));
      case ReportSortOption.date:
        list.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
      case ReportSortOption.none:
        break;
    }

    return list;
  }
}
