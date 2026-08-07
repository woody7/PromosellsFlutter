import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/models/transaction_report_row.dart';

class ReportApiException implements Exception {
  final String message;
  ReportApiException(this.message);
  @override
  String toString() => message;
}

/// Calls SampleTrackerAPIs' report endpoints
/// (Controllers/StockTransReportsController.cs).
class ReportApi {
  ReportApi._();

  static Future<List<TransactionReportRow>> fetchAllReports() async {
    final response = await http.get(ApiConfig.resolve('api/StockTransReports/GetAllSampleTransReports'));
    if (response.statusCode != 200) {
      throw ReportApiException('Could not load reports. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => TransactionReportRow.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<TransactionReportRow>> fetchReportDetails(String reportId) async {
    final response = await http.get(ApiConfig.resolve('api/StockTransReports/DisplayDropOffReport?ReportID=$reportId'));
    if (response.statusCode != 200) {
      throw ReportApiException('Could not load this report. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => TransactionReportRow.fromJson(e as Map<String, dynamic>)).toList();
  }
}
