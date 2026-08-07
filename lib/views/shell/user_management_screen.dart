import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/user_management_controller.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Port of UserManagement.js. Note: the backend's ListUsers endpoint only
/// projects { id, userName, email } — no roles — so the "Roles" column is
/// always blank here, same as it always is in the React version (its
/// `user.roles?.join(', ')` silently renders nothing since `roles` is never
/// present in the response either).
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserManagementController>()) {
      Get.put(UserManagementController());
    }
    final controller = Get.find<UserManagementController>();

    return SingleChildScrollView(
      padding: MySpacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.headlineSmall('User Management'),
          MySpacing.height(16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error.value != null) {
              return MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error);
            }
            final users = controller.users;
            return MyCard(
              paddingAll: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleSmall('All Users (${users.length})'),
                  MySpacing.height(8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Roles')),
                      ],
                      rows: users
                          .map((user) => DataRow(cells: [
                                DataCell(Text(user.email ?? '')),
                                DataCell(Text(user.userName)),
                                const DataCell(Text('')),
                              ]))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
