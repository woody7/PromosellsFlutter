/// Backend base URL for SampleTrackerAPIs.
///
/// Matches the React app's REACT_APP_API_BASE_URL convention (see
/// SampleTrackerFront2025/.env) — same backend, same default target.
/// Override per-build with:
///   flutter run --dart-define=API_BASE_URL=http://localhost:5254/
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://swlaccrapromosellapis.adroitbureau.com/',
  );

  static Uri resolve(String path) => Uri.parse('$baseUrl$path');
}
