import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/models/drop_off_result.dart';
import 'package:promosells_flutter/services/api_response_utils.dart';

class CustomerApiException implements Exception {
  final String message;
  CustomerApiException(this.message);
  @override
  String toString() => message;
}

/// Calls SampleTrackerAPIs' customer/stock-transaction endpoints for the
/// existing-customer flow (Controllers/ProspCustomersController.cs,
/// Controllers/StockTransactionsController.cs).
class CustomerApi {
  CustomerApi._();

  /// Port of customerlist.js's role-based endpoint choice: Admins see
  /// every customer, regular Users see only the ones they created.
  static Future<List<Customer>> fetchCustomers({required bool isAdmin, required String userEmail}) async {
    final uri = isAdmin
        ? ApiConfig.resolve('api/ProspCustomers/GetAllCustomers')
        : ApiConfig.resolve('api/ProspCustomers/GetAllCustomersOfUser?userEmail=$userEmail');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw CustomerApiException('Could not load customers. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Customer> fetchCustomerDetails(int customerId) async {
    final response = await http.get(ApiConfig.resolve('api/ProspCustomers/GetCustomerDetails?customerID=$customerId'));
    if (response.statusCode != 200) {
      throw CustomerApiException('Could not load customer details. Please try again.');
    }
    return Customer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<CustomerStockItem>> fetchCustomerStocks(int customerId) async {
    final response = await http.get(ApiConfig.resolve('api/StockTransReports/StocksWithOneCustomer?CustomerID=$customerId'));
    if (response.statusCode != 200) {
      throw CustomerApiException('Could not load this customer\'s stock. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => CustomerStockItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<CustomerIncident>> fetchCustomerIncidents(int customerId) async {
    final response = await http.get(ApiConfig.resolve('api/ProspCustomers/GetCustomerIncidents?customerID=$customerId'));
    if (response.statusCode != 200) {
      throw CustomerApiException('Could not load this customer\'s incident history. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => CustomerIncident.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `POST api/StockTransactions/PostDropOffExistingCustomer?WebCustID=`
  /// Same StockDataJson requirement as the new-customer drop-off (Stage 1)
  /// — see StocklistApi.submitDropOff for why.
  static Future<DropOffResult> submitDropOffExistingCustomer({
    required int customerId,
    required DateTime incidentDate,
    required String incidentType,
    required String incident,
    required String email,
    required List<List<int>> stockData,
    double? latitude,
    double? longitude,
    bool? demoAppInstalled,
    XFile? photo,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.resolve('api/StockTransactions/PostDropOffExistingCustomer?WebCustID=$customerId'),
    );

    request.fields.addAll({
      'incidentDate': incidentDate.toIso8601String(),
      'incidentType': incidentType,
      'incident': incident,
      'email': email,
      'StockDataJson': jsonEncode(stockData),
    });
    if (latitude != null) request.fields['Latitude'] = latitude.toString();
    if (longitude != null) request.fields['Longitude'] = longitude.toString();
    if (demoAppInstalled != null) request.fields['DemoAppInstalled'] = demoAppInstalled.toString();
    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('Photo', photo.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw CustomerApiException('Failed to submit the drop-off. Please try again.');
    }
    return DropOffResult(documentNumber: parseDocumentNumber(response.body));
  }

  /// `POST api/StockTransactions/PostPickUp` — plain JSON body, so the
  /// jagged StockArray binds natively (no StockDataJson workaround needed
  /// here; that's only required for the multipart drop-off endpoints).
  static Future<DropOffResult> submitPickup({
    required int customerId,
    required List<List<int>> stockArray,
    required DateTime incidentDate,
    required String incidentType,
    required String incident,
    required String email,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('api/StockTransactions/PostPickUp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'StockArray': stockArray,
        'WebCustID': customerId,
        'incidentDate': incidentDate.toIso8601String(),
        'incidentType': incidentType,
        'incident': incident,
        'email': email,
      }),
    );
    if (response.statusCode != 200) {
      throw CustomerApiException('Failed to submit the pickup. Please try again.');
    }
    return DropOffResult(documentNumber: parseDocumentNumber(response.body));
  }

  /// `POST api/StockTransactions/PostSale`
  static Future<DropOffResult> submitSale({
    required int customerId,
    required List<List<int>> stockArray,
    required DateTime incidentDate,
    required String incidentType,
    required String incident,
    required String email,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('api/StockTransactions/PostSale'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'StockArray': stockArray,
        'WebCustID': customerId,
        'incidentDate': incidentDate.toIso8601String(),
        'incidentType': incidentType,
        'incident': incident,
        'email': email,
      }),
    );
    if (response.statusCode != 200) {
      throw CustomerApiException('Failed to submit the sale. Please try again.');
    }
    return DropOffResult(documentNumber: parseDocumentNumber(response.body));
  }

  /// `POST api/ProspCustomers/UpdateCustomer`
  static Future<void> updateCustomer({
    required int customerId,
    required String name,
    required String company,
    required String contact,
    required String address,
    required String email,
    double? latitude,
    double? longitude,
    bool? demoAppInstalled,
    XFile? photo,
  }) async {
    final request = http.MultipartRequest('POST', ApiConfig.resolve('api/ProspCustomers/UpdateCustomer'));

    request.fields.addAll({
      'customerId': customerId.toString(),
      'name': name,
      'company': company,
      'contact': contact,
      'address': address,
      'Email': email,
    });
    if (latitude != null) request.fields['Latitude'] = latitude.toString();
    if (longitude != null) request.fields['Longitude'] = longitude.toString();
    if (demoAppInstalled != null) request.fields['DemoAppInstalled'] = demoAppInstalled.toString();
    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('Photo', photo.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw CustomerApiException('Failed to save customer. Please try again.');
    }
  }

  /// `POST api/ProspCustomers/AddCustomerIncident` — always returns 0 on
  /// success (StatusCode(200, 0) in the controller); there's no document
  /// number for a plain incident note.
  static Future<void> submitAddIncident({
    required int customerId,
    required DateTime validIncidentDate,
    required String incidentType,
    required String incident,
    required String email,
  }) async {
    final response = await http.post(
      ApiConfig.resolve('api/ProspCustomers/AddCustomerIncident'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': customerId,
        'validIncidentDate': '${validIncidentDate.year.toString().padLeft(4, '0')}-'
            '${validIncidentDate.month.toString().padLeft(2, '0')}-'
            '${validIncidentDate.day.toString().padLeft(2, '0')}',
        'incidentType': incidentType,
        'incident': incident,
        'email': email,
      }),
    );
    if (response.statusCode != 200) {
      throw CustomerApiException('Failed to add the incident. Please try again.');
    }
  }
}
