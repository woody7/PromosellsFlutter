import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/config/api_config.dart';
import 'package:promosells_flutter/controllers/customer_edit_controller.dart';
import 'package:promosells_flutter/widgets/my_button.dart';
import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';
import 'package:promosells_flutter/widgets/office_capture_fields.dart';

/// Port of CustomerEditPage.jsx.
class CustomerEditScreen extends StatefulWidget {
  const CustomerEditScreen({super.key, required this.customerId});

  final int customerId;

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  late final String _tag = 'customer_edit_${widget.customerId}';
  late final CustomerEditController controller;

  TextEditingController? _nameController;
  TextEditingController? _companyController;
  TextEditingController? _contactController;
  TextEditingController? _addressController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CustomerEditController(widget.customerId), tag: _tag);
  }

  /// Lazily seeds the text controllers once the customer has loaded. Called
  /// from build() — safe because it only constructs objects and doesn't
  /// trigger a rebuild itself, and `_nameController` guards it to run once.
  void _ensureTextControllers() {
    if (_nameController != null) return;
    _nameController = TextEditingController(text: controller.name.value);
    _companyController = TextEditingController(text: controller.company.value);
    _contactController = TextEditingController(text: controller.contact.value);
    _addressController = TextEditingController(text: controller.address.value);
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _companyController?.dispose();
    _contactController?.dispose();
    _addressController?.dispose();
    Get.delete<CustomerEditController>(tag: _tag);
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await controller.save();
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MyText.titleMedium('Edit Customer')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value != null && controller.customer.value == null) {
          return Center(child: MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error));
        }
        final customer = controller.customer.value;
        if (customer == null) {
          return const SizedBox.shrink();
        }
        _ensureTextControllers();

        return SingleChildScrollView(
          padding: MySpacing.all(16),
          child: MyCard(
            paddingAll: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.error.value != null) ...[
                  MyText.bodyMedium(controller.error.value!, color: Theme.of(context).colorScheme.error),
                  MySpacing.height(12),
                ],
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  onChanged: (v) => controller.name.value = v,
                ),
                MySpacing.height(12),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company', border: OutlineInputBorder()),
                  onChanged: (v) => controller.company.value = v,
                ),
                MySpacing.height(12),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact', border: OutlineInputBorder()),
                  onChanged: (v) => controller.contact.value = v,
                ),
                MySpacing.height(12),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                  onChanged: (v) => controller.address.value = v,
                ),
                MySpacing.height(16),
                Obx(() => OfficeCaptureFields(
                      demoAppInstalled: controller.demoAppInstalled.value,
                      onDemoAppInstalledChange: (v) => controller.demoAppInstalled.value = v,
                      onPhotoSelected: (file) => controller.photo.value = file,
                      onLocationCaptured: (lat, lng) {
                        controller.latitude.value = lat;
                        controller.longitude.value = lng;
                      },
                      existingPhotoUrl: customer.photoPath != null ? '${ApiConfig.baseUrl}${customer.photoPath}' : null,
                      existingLatitude: customer.latitude,
                      existingLongitude: customer.longitude,
                    )),
                MySpacing.height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => TextButton(
                          onPressed: controller.isSaving.value ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        )),
                    MySpacing.width(8),
                    Obx(() => MyButton(
                          onPressed: controller.isSaving.value ? null : _save,
                          child: controller.isSaving.value
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : MyText.bodyMedium('Save Changes', color: Colors.white),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
