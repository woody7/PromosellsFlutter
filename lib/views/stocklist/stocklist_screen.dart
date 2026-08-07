import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/stocklist_controller.dart';
import 'package:promosells_flutter/views/stocklist/widgets/customer_details_form.dart';
import 'package:promosells_flutter/views/stocklist/widgets/drop_off_confirmation_sheet.dart';
import 'package:promosells_flutter/views/stocklist/widgets/stock_group_accordion.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of Stocklist.js — new-customer drop-off entry point.
class StocklistScreen extends StatelessWidget {
  const StocklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StocklistController>()) {
      Get.put(StocklistController());
    }
    final controller = Get.find<StocklistController>();

    return SingleChildScrollView(
      padding: MySpacing.all(16),
      child: Column(
        children: [
          CustomerDetailsForm(controller: controller),
          MySpacing.height(16),
          StockGroupAccordion(controller: controller),
          MySpacing.height(24),
          Obx(() => MyButton.block(
                onPressed: controller.isFormValid
                    ? () {
                        if (controller.dropOffType.value.isEmpty) {
                          _showValidationMessage(context, 'Please select a Drop-Off Type before proceeding.');
                          return;
                        }
                        if (controller.incidentType.value.isEmpty) {
                          _showValidationMessage(context, 'Please select an Incident Type before proceeding.');
                          return;
                        }
                        showDropOffConfirmation(context, controller);
                      }
                    : null,
                child: MyText.titleSmall('Finish', color: Colors.white),
              )),
          MySpacing.height(24),
        ],
      ),
    );
  }

  void _showValidationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
