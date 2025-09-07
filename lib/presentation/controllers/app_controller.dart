import 'package:get/get.dart';
import 'package:darktales/core/services/storage_service.dart';
import 'package:darktales/core/constants/app_constants.dart';

class AppController extends GetxController {
  final StorageService _storageService = StorageService();

  // Observable variables
  final RxBool _isFirstLaunch = true.obs;
  final RxString _selectedLanguage = AppConstants.defaultLanguage.obs;
  final RxBool _isTutorialCompleted = false.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  bool get isFirstLaunch => _isFirstLaunch.value;
  String get selectedLanguage => _selectedLanguage.value;
  bool get isTutorialCompleted => _isTutorialCompleted.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _isLoading.value = true;

    try {
      await _storageService.init();

      // Load app state
      _isFirstLaunch.value = await _storageService.isFirstLaunch();
      _selectedLanguage.value = await _storageService.getSelectedLanguage();
      _isTutorialCompleted.value = await _storageService.isTutorialCompleted();
    } catch (e) {
      print('Error initializing app: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> setFirstLaunchCompleted() async {
    await _storageService.setFirstLaunchCompleted();
    _isFirstLaunch.value = false;
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    await _storageService.setSelectedLanguage(languageCode);
    _selectedLanguage.value = languageCode;
  }

  Future<void> setTutorialCompleted() async {
    await _storageService.setTutorialCompleted();
    _isTutorialCompleted.value = true;
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'pt-br':
        return 'Português (Brasil)';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'ja':
        return '日本語';
      case 'ru':
        return 'Русский';
      default:
        return languageCode;
    }
  }

  String getDifficultyName(String difficulty) {
    switch (difficulty) {
      case AppConstants.difficultyEasy:
        return 'Fácil';
      case AppConstants.difficultyNormal:
        return 'Normal';
      case AppConstants.difficultyHard:
        return 'Difícil';
      default:
        return difficulty;
    }
  }
}
