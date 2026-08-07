import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/models/session.dart';

class AuthApiException implements Exception {
  final String message;
  AuthApiException(this.message);
  @override
  String toString() => message;
}

/// Calls SampleTrackerAPIs' POST api/UserAccount/Login
/// (Controllers/UserAccountController.cs), which expects { Email, Password }
/// and returns { success, email, userName, roles } with no token/cookie.
class AuthApi {
  AuthApi._();

  static Future<Session> login({required String email, required String password}) async {
    final response = await http.post(
      ApiConfig.resolve('api/UserAccount/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email, 'Password': password}),
    );

    if (response.statusCode == 401) {
      throw AuthApiException('Invalid email or password.');
    }
    if (response.statusCode != 200) {
      throw AuthApiException('Could not reach the server. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final roles = (data['roles'] as List?)?.map((r) => r.toString()).toList() ?? <String>[];
    return Session(email: data['email'] as String, roles: roles);
  }
}
