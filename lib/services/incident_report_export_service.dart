import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:promosells_flutter/models/incident_summary.dart';

const _headers = ['Date', 'Customer', 'Phone', 'Incident Type', 'Incident', 'Details', 'Document No', 'Created By'];

/// Port of IncidentReportByDate.js's three export functions
/// (handleExportPDF, handleExport [CSV], handleExportText).
class IncidentReportExportService {
  IncidentReportExportService._();

  static List<String> _rowFor(IncidentSummary incident) => [
        _formatDate(incident.incidentDate),
        incident.customerName ?? 'N/A',
        incident.customerPhone ?? 'N/A',
        incident.incidentType ?? 'N/A',
        incident.incidentText ?? 'N/A',
        incident.details ?? 'N/A',
        incident.documentNo ?? 'N/A',
        incident.createdBy ?? 'N/A',
      ];

  static Future<List<int>> buildPdf({
    required List<IncidentSummary> incidents,
    required String dateRangeLabel,
    required String userLabel,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text('Incident Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Date Range: $dateRangeLabel', style: const pw.TextStyle(fontSize: 11)),
          pw.Text('User: $userLabel', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: _headers,
            data: [for (final incident in incidents) _rowFor(incident)],
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static List<int> buildCsv(List<IncidentSummary> incidents) {
    String quote(String value) => '"${value.replaceAll('"', '""')}"';
    final lines = [
      _headers.map(quote).join(','),
      for (final incident in incidents) _rowFor(incident).map(quote).join(','),
    ];
    return lines.join('\n').codeUnits;
  }

  static String buildCopyText({
    required List<IncidentSummary> incidents,
    required String dateRangeLabel,
    required String userLabel,
  }) {
    final lines = <String>['Incident Report', 'Date Range: $dateRangeLabel', 'User: $userLabel', ''];
    for (var i = 0; i < incidents.length; i++) {
      final incident = incidents[i];
      lines.add('${i + 1}. ${_formatDate(incident.incidentDate)} - ${incident.customerName ?? 'N/A'}');
      lines.add('Phone: ${incident.customerPhone ?? 'N/A'}');
      lines.add('Incident Type: ${incident.incidentType ?? 'N/A'}');
      lines.add('Incident: ${incident.incidentText ?? 'N/A'}');
      lines.add('Details: ${incident.details ?? 'N/A'}');
      lines.add('Document No: ${incident.documentNo ?? 'N/A'}');
      lines.add('Created By: ${incident.createdBy ?? 'N/A'}');
      lines.add('');
    }
    return lines.join('\n');
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
