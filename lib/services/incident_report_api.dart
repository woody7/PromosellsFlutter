import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/models/app_user.dart';
import 'package:promosells_flutter/models/incident_summary.dart';

class IncidentReportApiException implements Exception {
  final String message;
  IncidentReportApiException(this.message);
  @override
  String toString() => message;
}

/// Calls SampleTrackerAPIs' user-list and incident-report-by-date endpoints
/// (Controllers/UserAccountController.cs, Controllers/IncidentsController.cs).
class IncidentReportApi {
  IncidentReportApi._();

  static Future<List<AppUser>> fetchUsers() async {
    final response = await http.get(ApiConfig.resolve('api/UserAccount/ListUsers'));
    if (response.statusCode != 200) {
      throw IncidentReportApiException('Could not load the user list. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String _dateParam(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Admin view — all customers' incidents, optionally filtered to one user
  /// by username ("All" means unfiltered).
  static Future<List<IncidentSummary>> fetchIncidentsAll({
    required DateTime startDate,
    required DateTime endDate,
    String userName = 'All',
  }) async {
    final uri = ApiConfig.resolve('api/Incidents/GetCustomerIncidentsAll').replace(queryParameters: {
      'startDate': _dateParam(startDate),
      'endDate': _dateParam(endDate),
      'userName': userName,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw IncidentReportApiException('Failed to fetch incident reports');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => IncidentSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Regular-user view — only incidents created by the given user.
  static Future<List<IncidentSummary>> fetchIncidentsForUser({
    required DateTime startDate,
    required DateTime endDate,
    required String userEmail,
  }) async {
    final uri = ApiConfig.resolve('api/Incidents/GetUserCustomerIncidentsForUser').replace(queryParameters: {
      'startDate': _dateParam(startDate),
      'endDate': _dateParam(endDate),
      'userEmail': userEmail,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw IncidentReportApiException('Failed to fetch incident reports');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => IncidentSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}
