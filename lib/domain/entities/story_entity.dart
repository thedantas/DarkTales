abstract class StoryEntity {
  final int id;
  final Map<String, StoryContentEntity> translations;
  final String? difficulty;
  final String? category;

  const StoryEntity({
    required this.id,
    required this.translations,
    this.difficulty,
    this.category,
  });

  StoryContentEntity? getContentForLanguage(String languageCode) {
    return translations[languageCode];
  }

  List<String> get availableLanguages => translations.keys.toList();
}

abstract class StoryContentEntity {
  final String clueText;
  final String? imageClue;
  final String answerText;

  const StoryContentEntity({
    required this.clueText,
    this.imageClue,
    required this.answerText,
  });
}
