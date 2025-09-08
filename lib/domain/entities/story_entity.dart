abstract class StoryEntity {
  final int id;
  final Map<String, StoryContentEntity> translations;
  final String? difficulty;
  final String? category;
  final int level;
  final String image;

  const StoryEntity({
    required this.id,
    required this.translations,
    this.difficulty,
    this.category,
    required this.level,
    required this.image,
  });

  StoryContentEntity? getContentForLanguage(String languageCode) {
    return translations[languageCode];
  }

  List<String> get availableLanguages => translations.keys.toList();

  /// Obter nome do nível de dificuldade
  String get difficultyName {
    switch (level) {
      case 0:
        return 'Fácil';
      case 1:
        return 'Médio';
      case 2:
        return 'Difícil';
      default:
        return 'Desconhecido';
    }
  }

  /// Obter cor do nível de dificuldade
  String get difficultyColor {
    switch (level) {
      case 0:
        return 'green';
      case 1:
        return 'orange';
      case 2:
        return 'red';
      default:
        return 'grey';
    }
  }
}

abstract class StoryContentEntity {
  final String clueText;
  final String? imageClue;
  final String answerText;
  final String title;

  const StoryContentEntity({
    required this.clueText,
    this.imageClue,
    required this.answerText,
    required this.title,
  });
}
