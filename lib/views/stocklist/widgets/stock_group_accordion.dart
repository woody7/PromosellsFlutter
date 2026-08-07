import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/stocklist_controller.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';
import 'package:promosells_flutter/widgets/numeric_stepper_field.dart';

/// Port of Stocklist.js's stock-group accordion: items grouped by
/// stockGroup, each with a quantity picker.
class StockGroupAccordion extends StatelessWidget {
  const StockGroupAccordion({super.key, required this.controller});

  final StocklistController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingStock.value) {
        return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
      }
      if (controller.loadError.value != null) {
        return MyCard(
          paddingAll: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium(controller.loadError.value!, color: Theme.of(context).colorScheme.error),
              MySpacing.height(8),
              TextButton(onPressed: controller.loadStock, child: const Text('Retry')),
            ],
          ),
        );
      }

      final grouped = controller.groupedStock;
      return MyCard(
        paddingAll: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleMedium('Select Stock'),
            MySpacing.height(8),
            ...grouped.entries.map((group) => ExpansionTile(
                  title: MyText.bodyMedium(group.key, fontWeight: 600),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: MySpacing.only(left: 4, bottom: 8),
                  children: group.value
                      .map((item) => Padding(
                            padding: MySpacing.vertical(4),
                            child: Row(
                              children: [
                                Expanded(child: MyText.bodyMedium(item.description)),
                                Obx(() => NumericStepperField(
                                      value: controller.quantities[item.stockListId] ?? 0,
                                      onValueChange: (qty) => controller.setQuantity(item, qty),
                                    )),
                              ],
                            ),
                          ))
                      .toList(),
                )),
          ],
        ),
      );
    });
  }
}
