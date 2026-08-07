import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:promosells_flutter/models/transaction_report_row.dart';

/// Builds report export files. Where the React app screenshots the DOM
/// with html2canvas and embeds that image in a PDF, this builds a real
/// vector PDF via the `pdf` package's widget system — sharper output,
/// smaller file, selectable text, and no DOM to screenshot in the first
/// place on Flutter.
class ReportExportService {
  ReportExportService._();

  static Future<Uint8List> buildReportPdf({
    required String reportId,
    required List<TransactionReportRow> lines,
  }) async {
    final kind = reportKindFromId(reportId);
    final header = lines.first;
    final isPickup = kind == ReportKind.pickup;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(width: 10, height: 56, color: PdfColors.red800),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(reportKindLabel(kind), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Promosells', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(header.contactPerson, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(header.address, style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(header.companyName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Telephone Number: ${header.tel}'),
                  pw.Text('Report ID: ${header.reportId}'),
                  pw.Text('Date: ${_formatDate(header.date)}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Table.fromTextArray(
            headers: ['#', 'Samples', 'Transaction', 'Qty', 'Price', 'Amt'],
            data: [
              for (var i = 0; i < lines.length; i++)
                [
                  '${i + 1}',
                  lines[i].itemName ?? '',
                  lines[i].transactionType,
                  '${isPickup ? lines[i].pickupQuantity : lines[i].dropOffQuantity ?? ''}',
                  '${lines[i].price ?? ''}',
                  '${lines[i].amount ?? ''}',
                ],
            ],
          ),
          if (kind == ReportKind.dropOff) ...[
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(color: PdfColors.amber100),
              child: pw.Center(child: pw.Text('Please Note: This is not an Invoice')),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static List<int> buildReportExcel({
    required String reportId,
    required List<TransactionReportRow> lines,
  }) {
    final kind = reportKindFromId(reportId);
    final isPickup = kind == ReportKind.pickup;
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['Report'];
    workbook.setDefaultSheet('Report');

    sheet.appendRow(['#', 'Samples', 'Transaction', 'Qty', 'Price', 'Amt'].map(xls.TextCellValue.new).toList());
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      sheet.appendRow([
        xls.IntCellValue(i + 1),
        xls.TextCellValue(line.itemName ?? ''),
        xls.TextCellValue(line.transactionType),
        xls.DoubleCellValue((isPickup ? line.pickupQuantity : line.dropOffQuantity) ?? 0),
        xls.DoubleCellValue(line.price ?? 0),
        xls.DoubleCellValue(line.amount ?? 0),
      ]);
    }

    return workbook.encode()!;
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
