import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/main.dart';
import 'package:promosells_flutter/theme/app_theme.dart';

void main() {
  setUp(() {
    Get.reset();
    AppTheme.init();
    Get.put(AuthController());
  });

  testWidgets('shows the login screen when no session is present', (WidgetTester tester) async {
    await tester.pumpWidget(const PromosellsApp());
    await tester.pumpAndSettle();

    expect(find.text('Promosells'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });
}
