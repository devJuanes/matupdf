import 'matudb_secrets.dart' as secrets;

class MatuDbConfig {
  MatuDbConfig._();

  /// `--dart-define` tiene prioridad sobre `matudb_secrets.dart`.
  static const String url = String.fromEnvironment(
    'MATUDB_URL',
    defaultValue: secrets.matudbUrl,
  );

  static const String projectId = String.fromEnvironment(
    'MATUDB_PROJECT_ID',
    defaultValue: secrets.matudbProjectId,
  );

  static const String apiKey = String.fromEnvironment(
    'MATUDB_API_KEY',
    defaultValue: secrets.matudbApiKey,
  );

  static bool get isConfigured =>
      url.isNotEmpty && apiKey.isNotEmpty && projectId.isNotEmpty;

  static const String tableContacts = 'contact_messages';
  static const String tableDownloads = 'pdf_downloads';
  static const String tableDonations = 'voluntary_donations';
}
