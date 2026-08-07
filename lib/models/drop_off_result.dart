/// PostDropOff/PostDropOffExistingCustomer return either `0` (a
/// prospective customer + incident note was recorded but no stock items
/// were selected) or a generated document number string (a real drop-off
/// transaction was recorded).
class DropOffResult {
  final String? documentNumber;

  const DropOffResult({this.documentNumber});

  bool get hasStockMovement => documentNumber != null;
}
