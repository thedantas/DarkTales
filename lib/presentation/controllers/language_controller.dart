import 'package:get/get.dart';
import 'package:darktales/core/services/language_service.dart';
import 'package:darktales/core/services/analytics_service.dart';

class LanguageController extends GetxController {
  final LanguageService _languageService = LanguageService();

  // Observable variables
  final RxString _currentLanguage = ''.obs;
  final RxBool _isFirstTime = true.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  String get currentLanguage => _currentLanguage.value;
  bool get isFirstTime => _isFirstTime.value;
  bool get isLoading => _isLoading.value;

  // Setters
  void setCurrentLanguage(String languageCode) {
    _currentLanguage.value = languageCode;
  }

  // Lista de idiomas suportados
  List<MapEntry<String, String>> get supportedLanguages =>
      _languageService.getSupportedLanguagesList();

  @override
  void onInit() {
    super.onInit();
    _initializeLanguage();
  }

  /// Inicializar idioma
  Future<void> _initializeLanguage() async {
    _isLoading.value = true;

    try {
      // Verificar se é primeira vez
      _isFirstTime.value = await _languageService.isFirstTime();

      // Obter idioma atual
      _currentLanguage.value = await _languageService.getCurrentLanguage();

      print('🌍 Idioma inicializado: ${_currentLanguage.value}');
      print('🆕 É primeira vez: ${_isFirstTime.value}');
    } catch (e) {
      print('❌ Erro ao inicializar idioma: $e');
      _currentLanguage.value = LanguageService.defaultLanguage;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Alterar idioma
  Future<void> changeLanguage(String languageCode) async {
    print('🔄 Iniciando mudança de idioma para: $languageCode');
    print('🔄 Idioma atual antes da mudança: ${_currentLanguage.value}');

    if (!_languageService.isLanguageSupported(languageCode)) {
      print('❌ Idioma não suportado: $languageCode');
      return;
    }

    _isLoading.value = true;

    try {
      final oldLanguage = _currentLanguage.value;
      print('💾 Salvando idioma $languageCode no SharedPreferences...');
      await _languageService.setLanguage(languageCode);
      print('✅ Idioma salvo no SharedPreferences com sucesso!');

      _currentLanguage.value = languageCode;
      print('🔄 Idioma atualizado no controller: ${_currentLanguage.value}');

      print('🌍 Idioma atual após mudança: ${_currentLanguage.value}');

      // Log da mudança de idioma
      if (oldLanguage.isNotEmpty) {
        AnalyticsService.to.logLanguageChanged(oldLanguage, languageCode);
      } else {
        AnalyticsService.to
            .logLanguageSelected(languageCode, _isFirstTime.value);
      }

      // Marcar que não é mais primeira vez
      if (_isFirstTime.value) {
        await _languageService.setNotFirstTime();
        _isFirstTime.value = false;
      }

      print('🌍 Idioma alterado para: $languageCode');
      print(
          '✅ Idioma salvo com sucesso: ${_languageService.getLanguageName(languageCode)}');
    } catch (e) {
      print('❌ Erro ao alterar idioma: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Obter nome do idioma atual
  String getCurrentLanguageName() {
    return _languageService.getLanguageName(_currentLanguage.value);
  }

  /// Recarregar idioma do SharedPreferences
  Future<void> reloadLanguage() async {
    print('🔄 Recarregando idioma do SharedPreferences...');
    try {
      final savedLanguage = await _languageService.getCurrentLanguage();
      print('🔄 Idioma carregado do SharedPreferences: $savedLanguage');
      _currentLanguage.value = savedLanguage;
      print('✅ Idioma recarregado no controller: ${_currentLanguage.value}');
    } catch (e) {
      print('❌ Erro ao recarregar idioma: $e');
    }
  }

  /// Obter nome de um idioma específico
  String getLanguageName(String languageCode) {
    return _languageService.getLanguageName(languageCode);
  }

  /// Debug: Verificar estado atual do idioma
  Future<void> debugLanguageState() async {
    print('🔍 === DEBUG LANGUAGE STATE ===');
    print('🔍 Controller currentLanguage: ${_currentLanguage.value}');
    print('🔍 Controller isLoading: ${_isLoading.value}');
    print('🔍 Controller isFirstTime: ${_isFirstTime.value}');

    try {
      final savedLanguage = await _languageService.getCurrentLanguage();
      print('🔍 LanguageService getCurrentLanguage: $savedLanguage');
    } catch (e) {
      print('🔍 Erro ao obter idioma do LanguageService: $e');
    }

    print('🔍 === END DEBUG ===');
  }

  /// Verificar se um idioma está selecionado
  bool isLanguageSelected(String languageCode) {
    return _currentLanguage.value == languageCode;
  }

  /// Forçar primeira vez (para testes)
  Future<void> resetToFirstTime() async {
    await _languageService.resetSettings();
    _isFirstTime.value = true;
    _currentLanguage.value = _languageService.getDeviceLanguage();
  }

  /// Obter idioma do dispositivo
  String getDeviceLanguage() {
    return _languageService.getDeviceLanguage();
  }
}
