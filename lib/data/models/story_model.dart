import 'package:darktales/domain/entities/story_entity.dart';

class StoryModel extends StoryEntity {
  const StoryModel({
    required int id,
    required Map<String, StoryContentModel> translations,
    String? difficulty,
    String? category,
  }) : super(
          id: id,
          translations: translations,
          difficulty: difficulty,
          category: category,
        );

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final translations = <String, StoryContentModel>{};

    // Extract all language keys except 'id'
    json.forEach((key, value) {
      if (key != 'id' && value is Map<String, dynamic>) {
        translations[key] = StoryContentModel.fromJson(value);
      }
    });

    return StoryModel(
      id: json['id'] as int,
      translations: translations,
      difficulty: json['difficulty'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
    };

    translations.forEach((key, value) {
      data[key] = (value as StoryContentModel).toJson();
    });

    if (difficulty != null) data['difficulty'] = difficulty;
    if (category != null) data['category'] = category;

    return data;
  }

  StoryModel copyWith({
    int? id,
    Map<String, StoryContentModel>? translations,
    String? difficulty,
    String? category,
  }) {
    return StoryModel(
      id: id ?? this.id,
      translations:
          translations ?? this.translations.cast<String, StoryContentModel>(),
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
    );
  }
}

class StoryContentModel extends StoryContentEntity {
  const StoryContentModel({
    required String clueText,
    String? imageClue,
    required String answerText,
  }) : super(
          clueText: clueText,
          imageClue: imageClue,
          answerText: answerText,
        );

  factory StoryContentModel.fromJson(Map<String, dynamic> json) {
    return StoryContentModel(
      clueText: json['clue_text'] as String,
      imageClue: json['image_clue'] as String?,
      answerText: json['answer_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clue_text': clueText,
      'image_clue': imageClue,
      'answer_text': answerText,
    };
  }

  StoryContentModel copyWith({
    String? clueText,
    String? imageClue,
    String? answerText,
  }) {
    return StoryContentModel(
      clueText: clueText ?? this.clueText,
      imageClue: imageClue ?? this.imageClue,
      answerText: answerText ?? this.answerText,
    );
  }
}
