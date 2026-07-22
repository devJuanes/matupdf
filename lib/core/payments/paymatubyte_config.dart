class PayMatuByteConfig {
  PayMatuByteConfig._();

  static const String baseUrl = String.fromEnvironment(
    'PAYMATUBYTE_URL',
    defaultValue: 'https://pay.matubyte.com',
  );

  static const String apiKey = String.fromEnvironment(
    'PAYMATUBYTE_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => apiKey.isNotEmpty;
}
