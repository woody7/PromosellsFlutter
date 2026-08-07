import 'dart:convert';

/// Several StockTransactions endpoints return a plain document-number
/// string on success, but ASP.NET Core's default JSON output formatter
/// serializes a bare C# string as a JSON string literal (with quotes) and a
/// bare int as a JSON number (no quotes) — so the raw response body might
/// be `"DO202469"` or `0` depending on what the action returned. Normalize
/// either shape instead of assuming one.
///
/// Returns null for a "0" result (no stock movement recorded), otherwise
/// the document number.
String? parseDocumentNumber(String rawBody) {
  final raw = rawBody.trim();
  dynamic parsed;
  try {
    parsed = jsonDecode(raw);
  } catch (_) {
    parsed = raw;
  }
  final text = parsed.toString();
  return text == '0' ? null : text;
}
