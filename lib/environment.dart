late Environment _env;

Environment get env => _env;
String get idUser => "rkqeHCM9jxMSWMW1YmfM";

class Environment {
  final String apiBaseUrl;
  final String defaultAppLanguageCode;

  Environment._init({
    required this.apiBaseUrl,
    required this.defaultAppLanguageCode,
  });

  static void init({
    required String apiBaseUrl,
    String defaultAppLanguageCode = 'en',
  }) {
    _env = Environment._init(
      apiBaseUrl: apiBaseUrl,
      defaultAppLanguageCode: defaultAppLanguageCode,
    );
  }
}
