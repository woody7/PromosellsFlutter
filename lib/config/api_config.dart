/// Backend base URL for SampleTrackerAPIs.
///
/// Defaults to the DEMO backend (demopromosellapis) — test entries made
/// while building/testing this app must not land in the live production
/// database (swlaccrapromosellapis). Point at production explicitly only
/// for a real release build:
///   flutter run --dart-define=API_BASE_URL=https://swlaccrapromosellapis.adroitbureau.com/
///   flutter run --dart-define=API_BASE_URL=http://localhost:5254/
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://demopromosellapis.adroitbureau.com/',
  );

  static Uri resolve(String path) => Uri.parse('$baseUrl$path');
}
