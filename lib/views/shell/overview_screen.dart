import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Landing screen after login. The React app's Overview.jsx renders admin
/// dashboard cards/charts (stock, customers, sales) fed by AdminDashboard
/// endpoints — that comes in a later pass; this is the scaffold placeholder.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return SingleChildScrollView(
      padding: MySpacing.all(16),
      child: MyCard(
        paddingAll: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText.titleMedium('Welcome back'),
            MySpacing.height(4),
            Obx(() => MyText.bodyMedium(auth.session.value?.email ?? '', muted: true)),
          ],
        ),
      ),
    );
  }
}
