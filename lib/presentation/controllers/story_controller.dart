import 'package:get/get.dart';
import 'package:darktales/data/models/story_model.dart';
import 'package:darktales/core/services/firebase_service_v2.dart';
import 'package:darktales/core/services/storage_service.dart';
import 'package:darktales/core/services/analytics_service.dart';
import 'package:darktales/core/services/ads_service.dart';
import 'package:darktales/presentation/controllers/language_controller.dart';

class StoryController extends GetxController {
  final FirebaseServiceV2 _firebaseService = FirebaseServiceV2();
  final StorageService _storageService = StorageService();
  final LanguageController _languageController = Get.find<LanguageController>();

  // Observable variables
  final RxList<StoryModel> _stories = <StoryModel>[].obs;
  final RxList<StoryModel> _filteredStories = <StoryModel>[].obs;
  final RxList<int> _completedStories = <int>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedDifficulty = ''.obs;
  final RxString _selectedCategory = ''.obs;

  // Getters
  List<StoryModel> get stories => _stories;
  List<StoryModel> get filteredStories => _filteredStories;
  List<int> get completedStories => _completedStories;
  bool get isLoading => _isLoading.value;
  String get selectedDifficulty => _selectedDifficulty.value;
  String get selectedCategory => _selectedCategory.value;

  @override
  void onInit() {
    super.onInit();
    _loadStories();
    _loadCompletedStories();
  }

  Future<void> _loadStories() async {
    _isLoading.value = true;

    try {
      final stories = await _firebaseService.getStories();
      _stories.value = stories;
      _filteredStories.value = stories;

      // Debug: mostrar informações das histórias carregadas
      print('📚 Histórias carregadas: ${stories.length}');
      for (final story in stories) {
        print(
            '   📖 História ${story.id}: level=${story.level}, difficulty=${story.difficulty}');
      }
    } catch (e) {
      print('Error loading stories: $e');
      // Removido Get.snackbar para evitar problemas de contexto
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadCompletedStories() async {
    try {
      final completed = await _storageService.getCompletedStories();
      _completedStories.value = completed;
    } catch (e) {
      print('Error loading completed stories: $e');
    }
  }

  void filterStories({
    String? difficulty,
    String? category,
    String? language,
  }) {
    _selectedDifficulty.value = difficulty ?? '';
    _selectedCategory.value = category ?? '';

    var filtered = _stories.where((story) {
      bool matchesDifficulty = difficulty == null ||
          difficulty.isEmpty ||
          story.difficulty == difficulty;

      bool matchesCategory =
          category == null || category.isEmpty || story.category == category;

      bool matchesLanguage = language == null ||
          language.isEmpty ||
          story.translations.containsKey(language);

      return matchesDifficulty && matchesCategory && matchesLanguage;
    }).toList();

    _filteredStories.value = filtered;
  }

  void clearFilters() {
    _selectedDifficulty.value = '';
    _selectedCategory.value = '';
    _filteredStories.value = _stories;
  }

  Future<void> markStoryAsCompleted(int storyId) async {
    try {
      await _storageService.addCompletedStory(storyId);
      _completedStories.add(storyId);

      // Save progress
      await _saveProgress();

      // Mostrar anúncio interstitial após completar história
      AdsService.to.showInterstitialAd();
    } catch (e) {
      print('Error marking story as completed: $e');
    }
  }

  Future<void> markStoryAsIncomplete(int storyId) async {
    try {
      await _storageService.removeCompletedStory(storyId);
      _completedStories.remove(storyId);

      // Save progress
      await _saveProgress();
    } catch (e) {
      print('Error marking story as incomplete: $e');
    }
  }

  bool isStoryCompleted(int storyId) {
    return _completedStories.contains(storyId);
  }

  List<StoryModel> getStoriesByDifficulty(String difficulty) {
    // Mapear strings de dificuldade para níveis
    int level;
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        level = 0;
        break;
      case 'normal':
      case 'médio':
      case 'medium':
        level = 1;
        break;
      case 'difícil':
      case 'hard':
        level = 2;
        break;
      default:
        // Para compatibilidade com dados antigos
        return _stories
            .where((story) => story.difficulty == difficulty)
            .toList();
    }

    print(
        '🔍 Buscando histórias com nível $level para dificuldade "$difficulty"');
    final result = _stories.where((story) => story.level == level).toList();
    print('📊 Encontradas ${result.length} histórias com nível $level');

    return result;
  }

  List<StoryModel> getStoriesByLanguage(String language) {
    return _stories
        .where((story) => story.translations.containsKey(language))
        .toList();
  }

  StoryModel? getStoryById(int id) {
    try {
      return _stories.firstWhere((story) => story.id == id);
    } catch (e) {
      return null;
    }
  }

  void refreshStories() {
    _loadStories();
  }

  /// Obter histórias no idioma atual
  List<StoryModel> getStoriesInCurrentLanguage() {
    final currentLanguage = _languageController.currentLanguage;
    return _stories
        .where((story) => story.translations.containsKey(currentLanguage))
        .toList();
  }

  /// Obter conteúdo de uma história no idioma atual
  dynamic getStoryContentInCurrentLanguage(StoryModel story) {
    final currentLanguage = _languageController.currentLanguage;

    print('🔍 StoryController - Idioma atual: $currentLanguage');
    print(
        '🔍 StoryController - Idioma do controller: ${_languageController.currentLanguage}');
    print(
        '🔍 StoryController - Controller está carregando: ${_languageController.isLoading}');
    print(
        '🔍 Buscando conteúdo para história ${story.id} no idioma: $currentLanguage');
    print('📋 Idiomas disponíveis: ${story.availableLanguages}');
    print('📋 Traduções disponíveis: ${story.translations.keys.toList()}');

    // Debug do estado do idioma
    _languageController.debugLanguageState();

    // Verificar se o idioma está disponível
    if (!story.translations.containsKey(currentLanguage)) {
      print('❌ Idioma $currentLanguage não encontrado nas traduções');

      // Tentar fallback para pt-br se não for o idioma atual
      if (currentLanguage != 'pt-br' &&
          story.translations.containsKey('pt-br')) {
        print('🔄 Tentando fallback para pt-br');
        return story.getContentForLanguage('pt-br');
      }

      // Tentar fallback para en se não for o idioma atual
      if (currentLanguage != 'en' && story.translations.containsKey('en')) {
        print('🔄 Tentando fallback para en');
        return story.getContentForLanguage('en');
      }

      // Se não encontrar nenhum idioma, retornar o primeiro disponível
      if (story.translations.isNotEmpty) {
        final firstLanguage = story.translations.keys.first;
        print('🔄 Usando primeiro idioma disponível: $firstLanguage');
        return story.getContentForLanguage(firstLanguage);
      }

      return null;
    }

    final content = story.getContentForLanguage(currentLanguage);
    print('✅ Conteúdo encontrado: ${content != null ? "Sim" : "Não"}');
    return content;
  }

  /// Verificar se uma história tem conteúdo no idioma atual
  bool hasContentInCurrentLanguage(StoryModel story) {
    final currentLanguage = _languageController.currentLanguage;

    // Verificar se tem o idioma atual
    if (story.translations.containsKey(currentLanguage)) {
      return true;
    }

    // Verificar fallbacks
    if (story.translations.containsKey('pt-br') ||
        story.translations.containsKey('en') ||
        story.translations.isNotEmpty) {
      return true;
    }

    return false;
  }

  /// Obter idioma atual
  String get currentLanguage => _languageController.currentLanguage;

  /// Salvar progressão offline
  Future<void> _saveProgress() async {
    try {
      final totalStories = _stories.length;
      final completedStories = _completedStories.length;

      // Calcular progresso por dificuldade
      final difficultyProgress = <String, int>{};
      difficultyProgress['easy'] = _stories
          .where((s) => s.level == 0 && _completedStories.contains(s.id))
          .length;
      difficultyProgress['normal'] = _stories
          .where((s) => s.level == 1 && _completedStories.contains(s.id))
          .length;
      difficultyProgress['hard'] = _stories
          .where((s) => s.level == 2 && _completedStories.contains(s.id))
          .length;

      await _storageService.saveProgress(
        totalStories: totalStories,
        completedStories: completedStories,
        difficultyProgress: difficultyProgress,
      );

      // Log do progresso no Analytics
      AnalyticsService.to.logProgressUpdate(
        totalStories,
        completedStories,
        difficultyProgress,
      );

      print(
          '📊 Progresso salvo: $completedStories/$totalStories histórias completadas');
    } catch (e) {
      print('Erro ao salvar progresso: $e');
    }
  }
}
