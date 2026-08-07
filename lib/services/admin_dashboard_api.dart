import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/models/admin_dashboard.dart';

class AdminDashboardApiException implements Exception {
  final String message;
  AdminDashboardApiException(this.message);
  @override
  String toString() => message;
}

/// Calls SampleTrackerAPIs' 8 AdminDashboard endpoints
/// (Controllers/AdminDashboardController.cs) and combines them into one
/// result, matching Overview.jsx's single `fetchData` that awaits all 8.
class AdminDashboardApi {
  AdminDashboardApi._();

  static Future<AdminDashboardData> fetchAll() async {
    try {
      final results = await Future.wait([
        _getJson('api/AdminDashboard/AdminDashStockCard'),
        _getJson('api/AdminDashboard/AdminDashCustomerCard'),
        _getJson('api/AdminDashboard/StockGivenAsSamplesForPieChart'),
        _getJson('api/AdminDashboard/Top5CustomersWithSamples'),
        _getJson('api/AdminDashboard/SamplesDueForPickup'),
        _getJson('api/AdminDashboard/AdminDashSalesCard'),
        _getJson('api/AdminDashboard/UpcomingSaleReturnReco'),
        _getJson('api/AdminDashboard/Top5YearsWithTheirSales'),
      ]);

      return AdminDashboardData(
        stockCard: AdminStockCard.fromJson(results[0] as Map<String, dynamic>),
        customerCard: AdminCustomerCard.fromJson(results[1] as Map<String, dynamic>),
        samplesPieChart:
            (results[2] as List).map((e) => StockGroupSample.fromJson(e as Map<String, dynamic>)).toList(),
        topCustomers: (results[3] as List).map((e) => TopCustomerSample.fromJson(e as Map<String, dynamic>)).toList(),
        samplesPickup: (results[4] as List).map((e) => SamplePickupDue.fromJson(e as Map<String, dynamic>)).toList(),
        salesCard: AdminSalesCard.fromJson(results[5] as Map<String, dynamic>),
        upcomingSaleReturnReco:
            (results[6] as List).map((e) => UpcomingSaleReturnReco.fromJson(e as Map<String, dynamic>)).toList(),
        top5YearsWithSales: (results[7] as List).map((e) => YearSales.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } on AdminDashboardApiException {
      rethrow;
    } catch (_) {
      throw AdminDashboardApiException('Failed to load data. Please try again later.');
    }
  }

  static Future<dynamic> _getJson(String path) async {
    final response = await http.get(ApiConfig.resolve(path));
    if (response.statusCode != 200) {
      throw AdminDashboardApiException('Failed to load data. Please try again later.');
    }
    return jsonDecode(response.body);
  }
}
