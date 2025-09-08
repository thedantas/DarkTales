import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

/// Serviço centralizado para tagueamento com Firebase Analytics
class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find<AnalyticsService>();

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  @override
  Future<void> onInit() async {
    super.onInit();
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);

    // Configurações iniciais
    await _analytics.setAnalyticsCollectionEnabled(true);
    // await _analytics.setUserId(null); // Será definido quando necessário

    print('📊 Analytics Service inicializado');
  }

  /// Observer para navegação automática
  FirebaseAnalyticsObserver get observer => _observer;

  // ===== EVENTOS DE NAVEGAÇÃO =====

  /// Rastreia abertura de páginas
  Future<void> logPageView(String pageName,
      {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logScreenView(
        screenName: pageName,
        screenClass: pageName,
      );

      if (parameters != null) {
        await _analytics.logEvent(
          name: 'page_view',
          parameters: {
            'page_name': pageName,
            ...parameters,
          },
        );
      }

      print('📊 Page View: $pageName');
    } catch (e) {
      print('❌ Erro ao logar page view: $e');
    }
  }

  // ===== EVENTOS DE HISTÓRIAS =====

  /// Rastreia abertura de uma história
  Future<void> logStoryOpened(
      int storyId, String storyTitle, int difficulty) async {
    try {
      await _analytics.logEvent(
        name: 'story_opened',
        parameters: {
          'story_id': storyId,
          'story_title': storyTitle,
          'difficulty': difficulty,
          'difficulty_name': _getDifficultyName(difficulty),
        },
      );
      print(
          '📊 Story Opened: $storyTitle (ID: $storyId, Difficulty: $difficulty)');
    } catch (e) {
      print('❌ Erro ao logar story opened: $e');
    }
  }

  /// Rastreia visualização da solução
  Future<void> logSolutionViewed(int storyId, String storyTitle) async {
    try {
      await _analytics.logEvent(
        name: 'solution_viewed',
        parameters: {
          'story_id': storyId,
          'story_title': storyTitle,
        },
      );
      print('📊 Solution Viewed: $storyTitle (ID: $storyId)');
    } catch (e) {
      print('❌ Erro ao logar solution viewed: $e');
    }
  }

  /// Rastreia conclusão de história
  Future<void> logStoryCompleted(
      int storyId, String storyTitle, int difficulty, int timeSpent) async {
    try {
      await _analytics.logEvent(
        name: 'story_completed',
        parameters: {
          'story_id': storyId,
          'story_title': storyTitle,
          'difficulty': difficulty,
          'difficulty_name': _getDifficultyName(difficulty),
          'time_spent_seconds': timeSpent,
        },
      );
      print(
          '📊 Story Completed: $storyTitle (ID: $storyId, Time: ${timeSpent}s)');
    } catch (e) {
      print('❌ Erro ao logar story completed: $e');
    }
  }

  /// Rastreia compartilhamento de história
  Future<void> logStoryShared(
      int storyId, String storyTitle, String shareType) async {
    try {
      await _analytics.logEvent(
        name: 'story_shared',
        parameters: {
          'story_id': storyId,
          'story_title': storyTitle,
          'share_type': shareType, // 'story' ou 'solution'
        },
      );
      print('📊 Story Shared: $storyTitle (ID: $storyId, Type: $shareType)');
    } catch (e) {
      print('❌ Erro ao logar story shared: $e');
    }
  }

  // ===== EVENTOS DE FILTROS =====

  /// Rastreia uso de filtros
  Future<void> logFilterUsed(String filterType, String filterValue) async {
    try {
      await _analytics.logEvent(
        name: 'filter_used',
        parameters: {
          'filter_type': filterType, // 'difficulty', 'status', 'search'
          'filter_value': filterValue,
        },
      );
      print('📊 Filter Used: $filterType = $filterValue');
    } catch (e) {
      print('❌ Erro ao logar filter used: $e');
    }
  }

  // ===== EVENTOS DE IDIOMA =====

  /// Rastreia mudança de idioma
  Future<void> logLanguageChanged(
      String fromLanguage, String toLanguage) async {
    try {
      await _analytics.logEvent(
        name: 'language_changed',
        parameters: {
          'from_language': fromLanguage,
          'to_language': toLanguage,
        },
      );
      print('📊 Language Changed: $fromLanguage → $toLanguage');
    } catch (e) {
      print('❌ Erro ao logar language changed: $e');
    }
  }

  /// Rastreia seleção inicial de idioma
  Future<void> logLanguageSelected(String language, bool isFirstTime) async {
    try {
      await _analytics.logEvent(
        name: 'language_selected',
        parameters: {
          'language': language,
          'is_first_time': isFirstTime,
        },
      );
      print('📊 Language Selected: $language (First time: $isFirstTime)');
    } catch (e) {
      print('❌ Erro ao logar language selected: $e');
    }
  }

  // ===== EVENTOS DE CONFIGURAÇÕES =====

  /// Rastreia abertura de configurações
  Future<void> logSettingsOpened() async {
    try {
      await _analytics.logEvent(
        name: 'settings_opened',
      );
      print('📊 Settings Opened');
    } catch (e) {
      print('❌ Erro ao logar settings opened: $e');
    }
  }

  /// Rastreia mudanças nas configurações
  Future<void> logSettingChanged(
      String settingName, dynamic oldValue, dynamic newValue) async {
    try {
      await _analytics.logEvent(
        name: 'setting_changed',
        parameters: {
          'setting_name': settingName,
          'old_value': oldValue.toString(),
          'new_value': newValue.toString(),
        },
      );
      print('📊 Setting Changed: $settingName = $newValue');
    } catch (e) {
      print('❌ Erro ao logar setting changed: $e');
    }
  }

  // ===== EVENTOS DE PROGRESSO =====

  /// Rastreia progresso do usuário
  Future<void> logProgressUpdate(int totalStories, int completedStories,
      Map<String, int> difficultyProgress) async {
    try {
      await _analytics.logEvent(
        name: 'progress_update',
        parameters: {
          'total_stories': totalStories,
          'completed_stories': completedStories,
          'completion_percentage':
              ((completedStories / totalStories) * 100).round(),
          'easy_completed': difficultyProgress['easy'] ?? 0,
          'normal_completed': difficultyProgress['normal'] ?? 0,
          'hard_completed': difficultyProgress['hard'] ?? 0,
        },
      );
      print(
          '📊 Progress Update: $completedStories/$totalStories stories completed');
    } catch (e) {
      print('❌ Erro ao logar progress update: $e');
    }
  }

  /// Rastreia conquistas/marcos
  Future<void> logMilestoneReached(String milestoneType, int value) async {
    try {
      await _analytics.logEvent(
        name: 'milestone_reached',
        parameters: {
          'milestone_type':
              milestoneType, // 'first_story', '10_stories', 'all_easy', etc.
          'value': value,
        },
      );
      print('📊 Milestone Reached: $milestoneType = $value');
    } catch (e) {
      print('❌ Erro ao logar milestone reached: $e');
    }
  }

  // ===== EVENTOS DE ERRO =====

  /// Rastreia erros da aplicação
  Future<void> logError(String errorType, String errorMessage,
      {String? pageName}) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (pageName != null) 'page_name': pageName,
        },
      );
      print('📊 App Error: $errorType - $errorMessage');
    } catch (e) {
      print('❌ Erro ao logar app error: $e');
    }
  }

  // ===== EVENTOS DE PERFORMANCE =====

  /// Rastreia tempo de carregamento
  Future<void> logLoadTime(String operation, int milliseconds) async {
    try {
      await _analytics.logEvent(
        name: 'load_time',
        parameters: {
          'operation': operation, // 'stories_load', 'firebase_connect', etc.
          'milliseconds': milliseconds,
        },
      );
      print('📊 Load Time: $operation = ${milliseconds}ms');
    } catch (e) {
      print('❌ Erro ao logar load time: $e');
    }
  }

  // ===== EVENTOS PERSONALIZADOS =====

  /// Rastreia eventos personalizados
  Future<void> logCustomEvent(String eventName,
      {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters?.cast<String, Object>(),
      );
      print('📊 Custom Event: $eventName');
    } catch (e) {
      print('❌ Erro ao logar custom event: $e');
    }
  }

  // ===== MÉTODOS AUXILIARES =====

  String _getDifficultyName(int difficulty) {
    switch (difficulty) {
      case 0:
        return 'easy';
      case 1:
        return 'normal';
      case 2:
        return 'hard';
      default:
        return 'unknown';
    }
  }

  /// Define propriedades do usuário
  Future<void> setUserProperties({
    String? language,
    int? totalStoriesCompleted,
    String? preferredDifficulty,
  }) async {
    try {
      if (language != null) {
        await _analytics.setUserProperty(name: 'language', value: language);
      }
      if (totalStoriesCompleted != null) {
        await _analytics.setUserProperty(
            name: 'stories_completed', value: totalStoriesCompleted.toString());
      }
      if (preferredDifficulty != null) {
        await _analytics.setUserProperty(
            name: 'preferred_difficulty', value: preferredDifficulty);
      }
      print('📊 User Properties Updated');
    } catch (e) {
      print('❌ Erro ao definir user properties: $e');
    }
  }

  /// Inicia timer para medir tempo gasto
  DateTime? _startTime;

  void startTimer() {
    _startTime = DateTime.now();
  }

  int? getElapsedTime() {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  void resetTimer() {
    _startTime = null;
  }
}
