import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/theme/app_theme.dart';
import 'package:promosells_flutter/theme/theme_controller.dart';
import 'package:promosells_flutter/views/auth/login_screen.dart';
import 'package:promosells_flutter/views/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.init();
  await ThemeController.instance.init();

  final authController = Get.put(AuthController());
  await authController.restoreSession();

  runApp(const PromosellsApp());
}

class PromosellsApp extends StatelessWidget {
  const PromosellsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return GetMaterialApp(
          title: 'Promosells',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Reactively shows the login screen or the authenticated shell based on
/// whether a session is present — no named-route redirect dance needed
/// since there are only two top-level states.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() => auth.isLoggedIn ? const AppShell() : const LoginScreen());
  }
}
