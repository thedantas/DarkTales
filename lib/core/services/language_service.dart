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

    print('🌍 Idioma do dispositivo detectado: $languageCode');
    print('🌍 País do dispositivo: $countryCode');

    // Formar código completo (ex: pt-BR)
    final fullCode =
        countryCode != null ? '$languageCode-$countryCode' : languageCode;

    print('🌍 Código completo formado: $fullCode');

    // Verificar se o idioma completo está suportado
    if (supportedLanguages.containsKey(fullCode.toLowerCase())) {
      print('✅ Idioma completo suportado: ${fullCode.toLowerCase()}');
      return fullCode.toLowerCase();
    }

    // Verificar se apenas o código do idioma está suportado
    if (supportedLanguages.containsKey(languageCode)) {
      print('✅ Idioma base suportado: $languageCode');
      return languageCode;
    }

    // Retornar idioma padrão se não encontrar
    print('⚠️ Idioma não suportado, usando padrão: $defaultLanguage');
    return defaultLanguage;
  }

  /// Obter idioma salvo ou idioma do dispositivo
  Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    print('🔍 Verificando idioma salvo: $savedLanguage');

    if (savedLanguage != null &&
        supportedLanguages.containsKey(savedLanguage)) {
      print('✅ Usando idioma salvo: $savedLanguage');
      return savedLanguage;
    }

    // Se não há idioma salvo, usar o idioma do dispositivo
    print('⚠️ Nenhum idioma salvo encontrado, usando idioma do dispositivo');
    return getDeviceLanguage();
  }

  /// Salvar idioma selecionado
  Future<void> setLanguage(String languageCode) async {
    print('💾 LanguageService.setLanguage chamado com: $languageCode');

    if (!supportedLanguages.containsKey(languageCode)) {
      print('❌ Idioma não suportado: $languageCode');
      throw ArgumentError('Idioma não suportado: $languageCode');
    }

    final prefs = await SharedPreferences.getInstance();
    print(
        '💾 Salvando $languageCode no SharedPreferences com chave: $_languageKey');
    await prefs.setString(_languageKey, languageCode);

    // Verificar se foi salvo corretamente
    final savedValue = prefs.getString(_languageKey);
    print('✅ Idioma salvo no SharedPreferences: $savedValue');
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
