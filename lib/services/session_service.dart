import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:promosells_flutter/models/session.dart';

/// Mirrors the React app's sessionStorage keys (userEmail, userRole,
/// isLogin) — same shape, persisted via shared_preferences instead since
/// Flutter has no browser session storage. There is no auth token: the
/// backend's Login endpoint (SampleTrackerAPIs UserAccountController)
/// returns no cookie/JWT, only { email, userName, roles }, so this is
/// client-trusted session state, same as the web app.
class SessionService {
  SessionService._();

  static const _emailKey = 'userEmail';
  static const _rolesKey = 'userRoles';

  static Future<void> save(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, session.email);
    await prefs.setString(_rolesKey, jsonEncode(session.roles));
  }

  static Future<Session?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    if (email == null) return null;
    final rolesJson = prefs.getString(_rolesKey);
    final roles = rolesJson == null ? <String>[] : List<String>.from(jsonDecode(rolesJson) as List);
    return Session(email: email, roles: roles);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_rolesKey);
  }
}
