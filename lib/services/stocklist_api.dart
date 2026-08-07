import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/models/drop_off_result.dart';
import 'package:promosells_flutter/models/stock_list_entry.dart';

class StocklistApiException implements Exception {
  final String message;
  StocklistApiException(this.message);
  @override
  String toString() => message;
}

/// Calls SampleTrackerAPIs' stock-list and drop-off endpoints
/// (Controllers/StockListController.cs, Controllers/StockTransactionsController.cs).
class StocklistApi {
  StocklistApi._();

  static Future<List<StockListEntry>> fetchAll() async {
    final response = await http.get(ApiConfig.resolve('api/stocklist/GetallStock'));
    if (response.statusCode != 200) {
      throw StocklistApiException('Could not load the stock list. Please try again.');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => StockListEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Submits a new-customer drop-off (`POST api/StockTransactions/PostDropOff`).
  ///
  /// The endpoint takes `[FromForm] DropOffViewModel`, and the `Photo` field
  /// forces multipart/form-data — which means the jagged `stockData` array
  /// can't bind directly from form fields. The backend instead reads it from
  /// a `StockDataJson` string field
  /// (StockTransactionsController.cs: `data.stockData = ParseStockData(data.StockDataJson)`),
  /// so selected items are sent as a JSON-encoded `[[stockListId, quantity], ...]` string.
  static Future<DropOffResult> submitDropOff({
    required String companyName,
    required String tel,
    required String contactPerson,
    required String address,
    required String refNo,
    required String dropOffType,
    required DateTime date,
    required String incident,
    required String incidentType,
    required String email,
    required List<List<int>> stockData,
    double? latitude,
    double? longitude,
    bool? demoAppInstalled,
    XFile? photo,
  }) async {
    final request = http.MultipartRequest('POST', ApiConfig.resolve('api/StockTransactions/PostDropOff'));

    request.fields.addAll({
      'companyName': companyName,
      'tel': tel,
      'contactPerson': contactPerson,
      'address': address,
      'refNo': refNo,
      'dropOffType': dropOffType,
      'date': date.toIso8601String(),
      'incident': incident,
      'incidentType': incidentType,
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
      throw StocklistApiException('Failed to submit the drop-off. Please try again.');
    }

    // The response body is either a bare JSON number (0, no stock items) or
    // a JSON string (the generated document number) depending on what the
    // backend returned — normalize both instead of assuming one shape.
    final raw = response.body.trim();
    dynamic parsed;
    try {
      parsed = jsonDecode(raw);
    } catch (_) {
      parsed = raw;
    }
    final text = parsed.toString();
    return DropOffResult(documentNumber: text == '0' ? null : text);
  }
}
