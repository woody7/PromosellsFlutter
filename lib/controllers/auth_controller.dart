import 'package:get/get.dart';

import 'package:promosells_flutter/models/session.dart';
import 'package:promosells_flutter/services/auth_api.dart';
import 'package:promosells_flutter/services/session_service.dart';

class AuthController extends GetxController {
  final Rxn<Session> session = Rxn<Session>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isLoggedIn => session.value != null;
  bool get isAdmin => session.value?.isAdmin ?? false;

  Future<void> restoreSession() async {
    session.value = await SessionService.load();
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await AuthApi.login(email: email, password: password);
      await SessionService.save(result);
      session.value = result;
      return true;
    } on AuthApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await SessionService.clear();
    session.value = null;
  }
}
