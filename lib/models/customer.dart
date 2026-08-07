/// Mirrors the backend's Msextmj1 model (SampleTrackerAPIs/Models/Msextmj1.cs)
/// — a generically-named table reused for prospective customers. Only the
/// fields the app actually uses are named; the rest of that wide row is
/// irrelevant here.
class Customer {
  final int customerId; // msextmjIndex
  final String companyName; // vcmx1
  final String contactPerson; // vcmx2 (also doubles as the customer's display name)
  final String tel; // vcmx3
  final String address; // vcmx4
  final String? photoPath; // vcmx5 — relative path, prefix with ApiConfig.baseUrl to load
  final double? latitude; // flt1
  final double? longitude; // flt2
  final bool? demoAppInstalled; // bit1

  const Customer({
    required this.customerId,
    required this.companyName,
    required this.contactPerson,
    required this.tel,
    required this.address,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.demoAppInstalled,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['msextmjIndex'] as int,
      companyName: json['vcmx1'] as String? ?? '',
      contactPerson: json['vcmx2'] as String? ?? '',
      tel: json['vcmx3'] as String? ?? '',
      address: json['vcmx4'] as String? ?? '',
      photoPath: json['vcmx5'] as String?,
      latitude: (json['flt1'] as num?)?.toDouble(),
      longitude: (json['flt2'] as num?)?.toDouble(),
      demoAppInstalled: json['bit1'] as bool?,
    );
  }
}

/// A stock item currently held by a customer — from the anonymous
/// projection in StockTransReportsController.StocksWithOneCustomer.
class CustomerStockItem {
  final int stockListId;
  final String code;
  final String description;
  final double quantity; // flt1
  final int? elapsedDays;

  const CustomerStockItem({
    required this.stockListId,
    required this.code,
    required this.description,
    required this.quantity,
    this.elapsedDays,
  });

  factory CustomerStockItem.fromJson(Map<String, dynamic> json) {
    return CustomerStockItem(
      stockListId: json['stockListId'] as int,
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: (json['flt1'] as num?)?.toDouble() ?? 0,
      elapsedDays: json['elapsedDays'] as int?,
    );
  }
}

/// Mirrors Msextmj2 (SampleTrackerAPIs/Models/Msextmj2.cs), used here for a
/// customer's incident history.
class CustomerIncident {
  final DateTime? date; // date1
  final String incident; // vcmx1
  final String incidentType; // vc1
  final String? documentNumber; // vc2 — set when the incident came from a drop-off
  final String? createdBy;

  const CustomerIncident({
    required this.date,
    required this.incident,
    required this.incidentType,
    this.documentNumber,
    this.createdBy,
  });

  factory CustomerIncident.fromJson(Map<String, dynamic> json) {
    return CustomerIncident(
      date: json['date1'] != null ? DateTime.tryParse(json['date1'] as String) : null,
      incident: json['vcmx1'] as String? ?? '',
      incidentType: json['vc1'] as String? ?? '',
      documentNumber: (json['vc2'] as String?)?.isEmpty == true ? null : json['vc2'] as String?,
      createdBy: json['createdBy'] as String?,
    );
  }
}
