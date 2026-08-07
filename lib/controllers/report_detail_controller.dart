import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:promosells_flutter/models/transaction_report_row.dart';
import 'package:promosells_flutter/services/report_api.dart';
import 'package:promosells_flutter/services/report_export_service.dart';

/// Port of Report.js's data-loading + export actions.
///
/// React's Download and Share buttons both end up doing the same
/// thing here (surface the OS share sheet via `Printing.sharePdf`) — on
/// mobile there's no browser "downloads folder" to save into directly, and
/// the share sheet (with a "Save to Files"/"Save to Drive" option) is the
/// standard way apps let a user keep a file. Kept as two separate buttons
/// anyway since that's what the React version has, and the labels signal
/// different intent even if the underlying action is the same call.
class ReportDetailController extends GetxController {
  ReportDetailController(this.reportId);

  final String reportId;

  final RxList<TransactionReportRow> lines = <TransactionReportRow>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxBool isExporting = false.obs;

  ReportKind get kind => reportKindFromId(reportId);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      lines.value = await ReportApi.fetchReportDetails(reportId);
    } on ReportApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadOrSharePdf() async {
    if (lines.isEmpty) return;
    isExporting.value = true;
    try {
      final bytes = await ReportExportService.buildReportPdf(reportId: reportId, lines: lines);
      await Printing.sharePdf(bytes: bytes, filename: '$reportId.pdf');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> printPdf() async {
    if (lines.isEmpty) return;
    isExporting.value = true;
    try {
      final bytes = await ReportExportService.buildReportPdf(reportId: reportId, lines: lines);
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: '$reportId.pdf');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> shareExcel() async {
    if (lines.isEmpty) return;
    isExporting.value = true;
    try {
      final bytes = ReportExportService.buildReportExcel(reportId: reportId, lines: lines);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$reportId.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Report $reportId');
    } finally {
      isExporting.value = false;
    }
  }
}
