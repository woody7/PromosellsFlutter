/// Mirrors SampleTrackerAPIs' IncidentSummaryDto (DTOs/IncidentSummaryDto.cs),
/// returned by IncidentsController.GetCustomerIncidentsAll /
/// GetUserCustomerIncidentsForUser.
class IncidentSummary {
  final int id;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? incidentType;
  final String? incidentText;
  final String? documentNo;
  final String? details;
  final String? createdBy;
  final DateTime? incidentDate;

  const IncidentSummary({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.incidentType,
    this.incidentText,
    this.documentNo,
    this.details,
    this.createdBy,
    this.incidentDate,
  });

  factory IncidentSummary.fromJson(Map<String, dynamic> json) {
    return IncidentSummary(
      id: json['id'] as int,
      customerId: json['customerId'] as int?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      incidentType: json['incidentType'] as String?,
      incidentText: json['incidentText'] as String?,
      documentNo: (json['documentNo'] as String?)?.isEmpty == true ? null : json['documentNo'] as String?,
      details: json['details'] as String?,
      createdBy: json['createdBy'] as String?,
      incidentDate: json['incidentDate'] != null ? DateTime.tryParse(json['incidentDate'] as String) : null,
    );
  }
}
