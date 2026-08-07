import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/app_user.dart';
import 'package:promosells_flutter/models/incident_summary.dart';
import 'package:promosells_flutter/services/incident_report_api.dart';
import 'package:promosells_flutter/services/incident_report_export_service.dart';

/// Port of IncidentReportByDate.js's state.
class IncidentReportController extends GetxController {
  final RxList<AppUser> users = <AppUser>[].obs;
  final RxString selectedUserName = 'All'.obs;

  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  final RxList<IncidentSummary> incidents = <IncidentSummary>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  bool get isAdmin => Get.find<AuthController>().isAdmin;
  String get currentUserEmail => Get.find<AuthController>().session.value?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    if (isAdmin) loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      users.value = await IncidentReportApi.fetchUsers();
    } on IncidentReportApiException {
      // The user dropdown just stays empty (still has "All") — not fatal to the page.
    }
  }

  Future<void> search() async {
    if (startDate.value == null || endDate.value == null) {
      error.value = 'Please select both start and end dates';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final list = isAdmin
          ? await IncidentReportApi.fetchIncidentsAll(
              startDate: startDate.value!,
              endDate: endDate.value!,
              userName: selectedUserName.value,
            )
          : await IncidentReportApi.fetchIncidentsForUser(
              startDate: startDate.value!,
              endDate: endDate.value!,
              userEmail: currentUserEmail,
            );
      list.sort((a, b) => (b.incidentDate ?? DateTime(0)).compareTo(a.incidentDate ?? DateTime(0)));
      incidents.value = list;
    } on IncidentReportApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  /// Port of `displayUserName` in IncidentReportByDate.js — used in export headers.
  String get displayUserName => isAdmin ? selectedUserName.value : currentUserEmail;

  String get _dateRangeLabel => '${_fmt(startDate.value)} to ${_fmt(endDate.value)}';
  String _fmt(DateTime? d) => d == null ? '' : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final RxBool isExporting = false.obs;
  final RxBool copied = false.obs;

  Future<void> exportPdf() async {
    if (incidents.isEmpty) return;
    isExporting.value = true;
    try {
      final bytes = await IncidentReportExportService.buildPdf(
        incidents: incidents,
        dateRangeLabel: _dateRangeLabel,
        userLabel: displayUserName,
      );
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: 'incident-report-${_fmt(startDate.value)}-to-${_fmt(endDate.value)}.pdf');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportCsv() async {
    if (incidents.isEmpty) return;
    isExporting.value = true;
    try {
      final bytes = IncidentReportExportService.buildCsv(incidents);
      final dir = await getTemporaryDirectory();
      final filename = 'incident-report-${_fmt(startDate.value)}-to-${_fmt(endDate.value)}.csv';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Incident Report');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> copyAsText() async {
    if (incidents.isEmpty) return;
    final text = IncidentReportExportService.buildCopyText(
      incidents: incidents,
      dateRangeLabel: _dateRangeLabel,
      userLabel: displayUserName,
    );
    await Clipboard.setData(ClipboardData(text: text));
    copied.value = true;
    await Future.delayed(const Duration(seconds: 2));
    copied.value = false;
  }
}
