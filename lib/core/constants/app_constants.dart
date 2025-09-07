class AppConstants {
  // App Info
  static const String appName = 'Dark Tales';
  static const String appVersion = '1.0.0';

  // Firebase
  static const String firebaseStoriesPath = 'stories';

  // Languages
  static const String defaultLanguage = 'pt-br';
  static const List<String> supportedLanguages = [
    'pt-br',
    'en',
    'es',
    'fr',
    'de',
    'it',
    'ja',
    'ru',
  ];

  // Difficulty Levels
  static const String difficultyEasy = 'easy';
  static const String difficultyNormal = 'normal';
  static const String difficultyHard = 'hard';

  // Storage Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyCompletedStories = 'completed_stories';
  static const String keyTutorialCompleted = 'tutorial_completed';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  // UI Constants
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}
