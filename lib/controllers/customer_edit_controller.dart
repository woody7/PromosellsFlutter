import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/customer.dart';
import 'package:promosells_flutter/services/customer_api.dart';

/// Port of CustomerEditPage.jsx's state.
class CustomerEditController extends GetxController {
  CustomerEditController(this.customerId);

  final int customerId;

  final Rxn<Customer> customer = Rxn<Customer>();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxnString error = RxnString();

  final RxString name = ''.obs;
  final RxString company = ''.obs;
  final RxString contact = ''.obs;
  final RxString address = ''.obs;

  final Rxn<bool> demoAppInstalled = Rxn<bool>();
  final Rxn<XFile> photo = Rxn<XFile>();
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await CustomerApi.fetchCustomerDetails(customerId);
      customer.value = result;
      name.value = result.contactPerson;
      company.value = result.companyName;
      contact.value = result.tel;
      address.value = result.address;
      demoAppInstalled.value = result.demoAppInstalled;
    } on CustomerApiException {
      error.value = 'Failed to load customer details.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save() async {
    isSaving.value = true;
    error.value = null;
    try {
      final email = Get.find<AuthController>().session.value?.email ?? '';
      await CustomerApi.updateCustomer(
        customerId: customerId,
        name: name.value,
        company: company.value,
        contact: contact.value,
        address: address.value,
        email: email,
        latitude: latitude.value,
        longitude: longitude.value,
        demoAppInstalled: demoAppInstalled.value,
        photo: photo.value,
      );
      return true;
    } on CustomerApiException {
      error.value = 'Failed to save customer. Please try again.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
