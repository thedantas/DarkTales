import 'package:shared_preferences/shared_preferences.dart';
import 'package:darktales/core/constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First launch
  Future<bool> isFirstLaunch() async {
    return _prefs?.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchCompleted() async {
    await _prefs?.setBool(AppConstants.keyFirstLaunch, false);
  }

  // Language
  Future<String> getSelectedLanguage() async {
    return _prefs?.getString(AppConstants.keySelectedLanguage) ??
        AppConstants.defaultLanguage;
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    await _prefs?.setString(AppConstants.keySelectedLanguage, languageCode);
  }

  // Tutorial
  Future<bool> isTutorialCompleted() async {
    return _prefs?.getBool(AppConstants.keyTutorialCompleted) ?? false;
  }

  Future<void> setTutorialCompleted() async {
    await _prefs?.setBool(AppConstants.keyTutorialCompleted, true);
  }

  // Completed stories
  Future<List<int>> getCompletedStories() async {
    final storiesString = _prefs?.getString(AppConstants.keyCompletedStories);
    if (storiesString != null) {
      return storiesString.split(',').map(int.parse).toList();
    }
    return [];
  }

  Future<void> addCompletedStory(int storyId) async {
    final completedStories = await getCompletedStories();
    if (!completedStories.contains(storyId)) {
      completedStories.add(storyId);
      await _prefs?.setString(
          AppConstants.keyCompletedStories, completedStories.join(','));
    }
  }

  Future<void> removeCompletedStory(int storyId) async {
    final completedStories = await getCompletedStories();
    completedStories.remove(storyId);
    await _prefs?.setString(
        AppConstants.keyCompletedStories, completedStories.join(','));
  }

  Future<bool> isStoryCompleted(int storyId) async {
    final completedStories = await getCompletedStories();
    return completedStories.contains(storyId);
  }

  // Progress tracking
  Future<void> saveProgress({
    required int totalStories,
    required int completedStories,
    required Map<String, int> difficultyProgress,
  }) async {
    await _prefs?.setInt('total_stories', totalStories);
    await _prefs?.setInt('completed_stories', completedStories);

    // Save difficulty progress
    for (final entry in difficultyProgress.entries) {
      await _prefs?.setInt('difficulty_${entry.key}', entry.value);
    }
  }

  Future<Map<String, dynamic>> getProgress() async {
    final totalStories = _prefs?.getInt('total_stories') ?? 0;
    final completedStories = _prefs?.getInt('completed_stories') ?? 0;

    final difficultyProgress = <String, int>{};
    difficultyProgress['easy'] = _prefs?.getInt('difficulty_easy') ?? 0;
    difficultyProgress['normal'] = _prefs?.getInt('difficulty_normal') ?? 0;
    difficultyProgress['hard'] = _prefs?.getInt('difficulty_hard') ?? 0;

    return {
      'totalStories': totalStories,
      'completedStories': completedStories,
      'difficultyProgress': difficultyProgress,
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
