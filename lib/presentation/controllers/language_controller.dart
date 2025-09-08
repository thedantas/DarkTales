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
    if (!_languageService.isLanguageSupported(languageCode)) {
      Get.snackbar(
        'Erro',
        'Idioma não suportado: $languageCode',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isLoading.value = true;

    try {
      final oldLanguage = _currentLanguage.value;
      await _languageService.setLanguage(languageCode);
      _currentLanguage.value = languageCode;

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

      Get.snackbar(
        'Sucesso',
        'Idioma alterado para ${_languageService.getLanguageName(languageCode)}',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('🌍 Idioma alterado para: $languageCode');
    } catch (e) {
      print('❌ Erro ao alterar idioma: $e');
      Get.snackbar(
        'Erro',
        'Falha ao alterar idioma',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Obter nome do idioma atual
  String getCurrentLanguageName() {
    return _languageService.getLanguageName(_currentLanguage.value);
  }

  /// Obter nome de um idioma específico
  String getLanguageName(String languageCode) {
    return _languageService.getLanguageName(languageCode);
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
