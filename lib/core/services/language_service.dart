import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  static const String _isFirstTimeKey = 'is_first_time';

  // Idiomas suportados
  static const Map<String, String> supportedLanguages = {
    'pt-br': 'Português (Brasil)',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'ja': '日本語',
    'ru': 'Русский',
  };

  // Idioma padrão
  static const String defaultLanguage = 'pt-br';

  /// Obter idioma atual do dispositivo
  String getDeviceLanguage() {
    final locale = PlatformDispatcher.instance.locale;
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;

    // Formar código completo (ex: pt-BR)
    final fullCode =
        countryCode != null ? '$languageCode-$countryCode' : languageCode;

    // Verificar se o idioma completo está suportado
    if (supportedLanguages.containsKey(fullCode.toLowerCase())) {
      return fullCode.toLowerCase();
    }

    // Verificar se apenas o código do idioma está suportado
    if (supportedLanguages.containsKey(languageCode)) {
      return languageCode;
    }

    // Retornar idioma padrão se não encontrar
    return defaultLanguage;
  }

  /// Obter idioma salvo ou idioma do dispositivo
  Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null &&
        supportedLanguages.containsKey(savedLanguage)) {
      return savedLanguage;
    }

    // Se não há idioma salvo, usar o idioma do dispositivo
    return getDeviceLanguage();
  }

  /// Salvar idioma selecionado
  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      throw ArgumentError('Idioma não suportado: $languageCode');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Verificar se é a primeira vez que o app é aberto
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  /// Marcar que não é mais a primeira vez
  Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  /// Obter nome do idioma
  String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? languageCode;
  }

  /// Obter lista de idiomas suportados
  List<MapEntry<String, String>> getSupportedLanguagesList() {
    return supportedLanguages.entries.toList();
  }

  /// Verificar se um idioma está suportado
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }

  /// Resetar configurações (para testes)
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
    await prefs.remove(_isFirstTimeKey);
  }
}
