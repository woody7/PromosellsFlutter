import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/models/drop_off_result.dart';
import 'package:promosells_flutter/models/stock_list_entry.dart';
import 'package:promosells_flutter/services/stocklist_api.dart';

/// Backs the new-customer drop-off screen — port of Stocklist.js's state
/// and submit flow.
class StocklistController extends GetxController {
  final RxList<StockListEntry> stockEntries = <StockListEntry>[].obs;
  final RxBool isLoadingStock = true.obs;
  final RxnString loadError = RxnString();

  /// stockListId -> selected quantity. Only entries with quantity > 0 are
  /// treated as selected (mirrors selectedItems in Stocklist.js).
  final RxMap<int, int> quantities = <int, int>{}.obs;

  // Customer detail fields (Customerdetails.js form)
  final RxString companyName = ''.obs;
  final RxString contactPerson = ''.obs;
  final RxString tel = ''.obs;
  final RxString address = ''.obs;
  final RxString refNo = ''.obs;
  final RxString dropOffType = ''.obs;
  final RxString incidentType = ''.obs;
  final RxString incident = ''.obs;
  final Rx<DateTime> date = DateTime.now().obs;

  // React validates the phone with a debounced regex check; here it's just
  // validated immediately on change — the debounce didn't serve a visible
  // purpose beyond delaying the same synchronous check.
  final RxBool isPhoneValid = true.obs;

  final Rxn<XFile> photo = Rxn<XFile>();
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final Rxn<bool> demoAppInstalled = Rxn<bool>();

  final RxBool isSubmitting = false.obs;
  final RxnString submitError = RxnString();
  final Rxn<DropOffResult> lastResult = Rxn<DropOffResult>();

  @override
  void onInit() {
    super.onInit();
    loadStock();
  }

  Future<void> loadStock() async {
    isLoadingStock.value = true;
    loadError.value = null;
    try {
      stockEntries.value = await StocklistApi.fetchAll();
    } on StocklistApiException catch (e) {
      loadError.value = e.message;
    } finally {
      isLoadingStock.value = false;
    }
  }

  Map<String, List<StockListEntry>> get groupedStock {
    final grouped = <String, List<StockListEntry>>{};
    for (final entry in stockEntries) {
      grouped.putIfAbsent(entry.stockGroup, () => []).add(entry);
    }
    return grouped;
  }

  List<SelectedStockItem> get selectedItems {
    return stockEntries
        .where((e) => (quantities[e.stockListId] ?? 0) > 0)
        .map((e) => SelectedStockItem(entry: e, quantity: quantities[e.stockListId]!))
        .toList();
  }

  void setQuantity(StockListEntry entry, int qty) {
    if (qty <= 0) {
      quantities.remove(entry.stockListId);
    } else {
      quantities[entry.stockListId] = qty;
    }
  }

  void onTelChanged(String value) {
    tel.value = value;
    isPhoneValid.value = RegExp(r'^\d{10}$').hasMatch(value);
  }

  /// Mirrors Stocklist.js's isFormValid(): the four core customer fields
  /// must be filled in — everything else (dates, stock selection) is
  /// optional at this stage.
  bool get isFormValid => companyName.value.isNotEmpty && tel.value.isNotEmpty && contactPerson.value.isNotEmpty && address.value.isNotEmpty;

  Future<bool> submit() async {
    isSubmitting.value = true;
    submitError.value = null;
    try {
      final email = Get.find<AuthController>().session.value?.email ?? '';
      final result = await StocklistApi.submitDropOff(
        companyName: companyName.value,
        tel: tel.value,
        contactPerson: contactPerson.value,
        address: address.value,
        refNo: refNo.value,
        dropOffType: dropOffType.value,
        date: date.value,
        incident: incident.value,
        incidentType: incidentType.value,
        email: email,
        stockData: selectedItems.map((item) => [item.entry.stockListId, item.quantity]).toList(),
        latitude: latitude.value,
        longitude: longitude.value,
        demoAppInstalled: demoAppInstalled.value,
        photo: photo.value,
      );
      lastResult.value = result;
      return true;
    } on StocklistApiException catch (e) {
      submitError.value = e.message;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetForm() {
    quantities.clear();
    companyName.value = '';
    contactPerson.value = '';
    tel.value = '';
    address.value = '';
    refNo.value = '';
    dropOffType.value = '';
    incidentType.value = '';
    incident.value = '';
    date.value = DateTime.now();
    isPhoneValid.value = true;
    photo.value = null;
    latitude.value = null;
    longitude.value = null;
    demoAppInstalled.value = null;
    lastResult.value = null;
  }
}
