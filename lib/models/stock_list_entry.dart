/// Mirrors the backend's StockList model (SampleTrackerAPIs/Models/StockList.cs),
/// which serializes to camelCase JSON. Only the fields the drop-off flow
/// actually needs are modeled — the backend row has many more (pricing,
/// reorder levels, etc.) that aren't used here.
class StockListEntry {
  final int stockListId;
  final String code;
  final String description;
  final String stockGroup;

  const StockListEntry({
    required this.stockListId,
    required this.code,
    required this.description,
    required this.stockGroup,
  });

  factory StockListEntry.fromJson(Map<String, dynamic> json) {
    return StockListEntry(
      stockListId: json['stockListId'] as int,
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stockGroup: json['stockGroup'] as String? ?? '',
    );
  }
}

/// A stock item the user has picked a quantity for — the Flutter
/// equivalent of the `selectedItems` array in Stocklist.js.
class SelectedStockItem {
  final StockListEntry entry;
  final int quantity;

  const SelectedStockItem({required this.entry, required this.quantity});
}
