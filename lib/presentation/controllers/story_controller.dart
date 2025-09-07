import 'package:get/get.dart';
import 'package:darktales/data/models/story_model.dart';
import 'package:darktales/core/services/firebase_service.dart';
import 'package:darktales/core/services/storage_service.dart';

class StoryController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();

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
    } catch (e) {
      print('Error loading stories: $e');
      Get.snackbar(
        'Erro',
        'Falha ao carregar as histórias',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    } catch (e) {
      print('Error marking story as completed: $e');
    }
  }

  Future<void> markStoryAsIncomplete(int storyId) async {
    try {
      await _storageService.removeCompletedStory(storyId);
      _completedStories.remove(storyId);
    } catch (e) {
      print('Error marking story as incomplete: $e');
    }
  }

  bool isStoryCompleted(int storyId) {
    return _completedStories.contains(storyId);
  }

  List<StoryModel> getStoriesByDifficulty(String difficulty) {
    return _stories.where((story) => story.difficulty == difficulty).toList();
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
}
