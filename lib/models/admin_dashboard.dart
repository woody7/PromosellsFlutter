/// Mirrors SampleTrackerAPIs' MyObjects/AdminDashboard*Card.cs and the
/// anonymous/DB-projected shapes AdminDashDB's chart queries return
/// (Controllers/AdminDashboardController.cs) — field names taken directly
/// from Overview.jsx's usage since those are the working, already-verified
/// shapes.
class AdminStockCard {
  final int totalStockCategories;
  final int totalStockItems;
  final double totalStockQuantity;
  final double totalStockValue;

  const AdminStockCard({
    required this.totalStockCategories,
    required this.totalStockItems,
    required this.totalStockQuantity,
    required this.totalStockValue,
  });

  factory AdminStockCard.fromJson(Map<String, dynamic> json) => AdminStockCard(
        totalStockCategories: json['totalStockCategories'] as int? ?? 0,
        totalStockItems: json['totalStockItems'] as int? ?? 0,
        totalStockQuantity: (json['totalStockQuantity'] as num?)?.toDouble() ?? 0,
        totalStockValue: (json['totalStockValue'] as num?)?.toDouble() ?? 0,
      );
}

class AdminCustomerCard {
  final int totalCustomers;
  final int totalCustomersWithStock;
  final int totalCustomersWhoGeneratedSales;

  const AdminCustomerCard({
    required this.totalCustomers,
    required this.totalCustomersWithStock,
    required this.totalCustomersWhoGeneratedSales,
  });

  factory AdminCustomerCard.fromJson(Map<String, dynamic> json) => AdminCustomerCard(
        totalCustomers: json['totalCustomers'] as int? ?? 0,
        totalCustomersWithStock: json['totalCustomersWithStock'] as int? ?? 0,
        totalCustomersWhoGeneratedSales: json['totalCustomersWhoGeneratedSales'] as int? ?? 0,
      );
}

class AdminSalesCard {
  final double salesToDate;
  final double salesThisYear;
  final double salesThisMonth;
  final double salesThisWeek;

  const AdminSalesCard({
    required this.salesToDate,
    required this.salesThisYear,
    required this.salesThisMonth,
    required this.salesThisWeek,
  });

  factory AdminSalesCard.fromJson(Map<String, dynamic> json) => AdminSalesCard(
        salesToDate: (json['salesToDate'] as num?)?.toDouble() ?? 0,
        salesThisYear: (json['salesThisYear'] as num?)?.toDouble() ?? 0,
        salesThisMonth: (json['salesThisMonth'] as num?)?.toDouble() ?? 0,
        salesThisWeek: (json['salesThisWeek'] as num?)?.toDouble() ?? 0,
      );
}

class StockGroupSample {
  final String stockGroup;
  final double quantity;

  const StockGroupSample({required this.stockGroup, required this.quantity});

  factory StockGroupSample.fromJson(Map<String, dynamic> json) => StockGroupSample(
        stockGroup: json['stockGroup'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      );
}

class TopCustomerSample {
  final String customerName;
  final double total;

  const TopCustomerSample({required this.customerName, required this.total});

  factory TopCustomerSample.fromJson(Map<String, dynamic> json) => TopCustomerSample(
        customerName: json['customerName'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0,
      );
}

class SamplePickupDue {
  final String customerName;
  final String telephone;
  final String stockDescription;
  final double quantity;

  const SamplePickupDue({
    required this.customerName,
    required this.telephone,
    required this.stockDescription,
    required this.quantity,
  });

  factory SamplePickupDue.fromJson(Map<String, dynamic> json) => SamplePickupDue(
        customerName: json['customerName'] as String? ?? '',
        telephone: json['telephone'] as String? ?? '',
        stockDescription: json['stockDescription'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      );
}

class YearSales {
  final String year;
  final double sales;

  const YearSales({required this.year, required this.sales});

  factory YearSales.fromJson(Map<String, dynamic> json) => YearSales(
        year: json['year'].toString(),
        sales: (json['sales'] as num?)?.toDouble() ?? 0,
      );
}

class UpcomingSaleReturnReco {
  final String customer;
  final String telNo;
  final DateTime? recoDate;
  final double value;

  const UpcomingSaleReturnReco({required this.customer, required this.telNo, this.recoDate, required this.value});

  factory UpcomingSaleReturnReco.fromJson(Map<String, dynamic> json) => UpcomingSaleReturnReco(
        customer: json['customer'] as String? ?? '',
        telNo: json['telNo'] as String? ?? '',
        recoDate: json['recoDate'] != null ? DateTime.tryParse(json['recoDate'] as String) : null,
        value: (json['value'] as num?)?.toDouble() ?? 0,
      );
}

class AdminDashboardData {
  final AdminStockCard stockCard;
  final AdminCustomerCard customerCard;
  final AdminSalesCard salesCard;
  final List<StockGroupSample> samplesPieChart;
  final List<TopCustomerSample> topCustomers;
  final List<SamplePickupDue> samplesPickup;
  final List<YearSales> top5YearsWithSales;
  final List<UpcomingSaleReturnReco> upcomingSaleReturnReco;

  const AdminDashboardData({
    required this.stockCard,
    required this.customerCard,
    required this.salesCard,
    required this.samplesPieChart,
    required this.topCustomers,
    required this.samplesPickup,
    required this.top5YearsWithSales,
    required this.upcomingSaleReturnReco,
  });
}
