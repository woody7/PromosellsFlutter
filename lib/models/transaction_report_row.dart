/// Mirrors the backend's Td3/Td4 models (SampleTrackerAPIs/Models/Td3.cs,
/// Td4.cs) — structurally identical wide rows reused for both the report
/// list (Td4, one row per transaction) and report detail (Td3, one row per
/// line item within a transaction). Only the fields the reports UI uses are
/// named.
class TransactionReportRow {
  final int tdIndex;
  final String companyName; // vcmx1
  final String contactPerson; // vcmx2
  final String tel; // vcmx3
  final String address; // vcmx4
  final String reportId; // vcmx5 — the document number (e.g. DO202469)
  final String transactionType; // vcmx7 — e.g. "sample", "return"
  final String? itemName; // vcmx8 — only populated on detail (Td3) rows
  final double? dropOffQuantity; // flt1
  final double? pickupQuantity; // flt2
  final double? price; // flt3
  final double? amount; // flt4
  final DateTime? date; // date1

  const TransactionReportRow({
    required this.tdIndex,
    required this.companyName,
    required this.contactPerson,
    required this.tel,
    required this.address,
    required this.reportId,
    required this.transactionType,
    this.itemName,
    this.dropOffQuantity,
    this.pickupQuantity,
    this.price,
    this.amount,
    this.date,
  });

  factory TransactionReportRow.fromJson(Map<String, dynamic> json) {
    return TransactionReportRow(
      tdIndex: json['tdIndex'] as int,
      companyName: json['vcmx1'] as String? ?? '',
      contactPerson: json['vcmx2'] as String? ?? '',
      tel: json['vcmx3'] as String? ?? '',
      address: json['vcmx4'] as String? ?? '',
      reportId: json['vcmx5'] as String? ?? '',
      transactionType: json['vcmx7'] as String? ?? '',
      itemName: json['vcmx8'] as String?,
      dropOffQuantity: (json['flt1'] as num?)?.toDouble(),
      pickupQuantity: (json['flt2'] as num?)?.toDouble(),
      price: (json['flt3'] as num?)?.toDouble(),
      amount: (json['flt4'] as num?)?.toDouble(),
      date: json['date1'] != null ? DateTime.tryParse(json['date1'] as String) : null,
    );
  }
}

enum ReportKind { dropOff, pickup, invoice, unknown }

/// Port of Report.js's reportID.includes("DO"/"PU"/"INV") logic.
ReportKind reportKindFromId(String reportId) {
  if (reportId.contains('DO')) return ReportKind.dropOff;
  if (reportId.contains('PU')) return ReportKind.pickup;
  if (reportId.contains('INV')) return ReportKind.invoice;
  return ReportKind.unknown;
}

String reportKindLabel(ReportKind kind) {
  switch (kind) {
    case ReportKind.dropOff:
      return 'Drop Off Report';
    case ReportKind.pickup:
      return 'Pick Up Report';
    case ReportKind.invoice:
      return 'Invoice Report';
    case ReportKind.unknown:
      return 'Report';
  }
}
