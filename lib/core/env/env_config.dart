class EnvConfig {
  EnvConfig._();

  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8000',
      );

  static bool get debug => const bool.fromEnvironment(
        'DEBUG',
        defaultValue: true,
      );
}
