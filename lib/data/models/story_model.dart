import 'package:darktales/domain/entities/story_entity.dart';

class StoryModel extends StoryEntity {
  const StoryModel({
    required int id,
    required Map<String, StoryContentModel> translations,
    String? difficulty,
    String? category,
    required int level,
    required String image,
  }) : super(
          id: id,
          translations: translations,
          difficulty: difficulty,
          category: category,
          level: level,
          image: image,
        );

  factory StoryModel.fromJson(Map json) {
    final translations = <String, StoryContentModel>{};

    print('🔍 StoryModel.fromJson - Dados recebidos: $json');
    print('🔑 Chaves no JSON: ${json.keys.toList()}');

    // Extract all language keys except 'id', 'difficulty', 'category'
    json.forEach((key, value) {
      print('🔍 Processando chave: $key (tipo: ${value.runtimeType})');
      print('   Valor: $value');

      if (key != 'id' &&
          key != 'difficulty' &&
          key != 'category' &&
          key != 'level' &&
          key != 'image' &&
          value is Map) {
        print('✅ Adicionando tradução para idioma: $key');
        try {
          translations[key] = StoryContentModel.fromJson(value);
          print('✅ Tradução $key adicionada com sucesso');
        } catch (e) {
          print('❌ Erro ao processar tradução $key: $e');
          print('   Dados problemáticos: $value');
        }
      } else {
        print('⏭️ Pulando chave $key (não é tradução)');
        print(
            '   Razão: ${key == 'id' ? 'é ID' : key == 'difficulty' ? 'é difficulty' : key == 'category' ? 'é category' : key == 'level' ? 'é level' : key == 'image' ? 'é image' : 'não é Map<String, dynamic>'}');
      }
    });

    print('📋 Total de traduções encontradas: ${translations.length}');
    print('🌐 Idiomas: ${translations.keys.toList()}');

    return StoryModel(
      id: json['id'] as int,
      translations: translations,
      difficulty: json['difficulty'] as String?,
      category: json['category'] as String?,
      level: json['level'] as int,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'level': level,
      'image': image,
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
    int? level,
    String? image,
  }) {
    return StoryModel(
      id: id ?? this.id,
      translations:
          translations ?? this.translations.cast<String, StoryContentModel>(),
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      level: level ?? this.level,
      image: image ?? this.image,
    );
  }
}

class StoryContentModel extends StoryContentEntity {
  const StoryContentModel({
    required String clueText,
    String? imageClue,
    required String answerText,
    required String title,
  }) : super(
          clueText: clueText,
          imageClue: imageClue,
          answerText: answerText,
          title: title,
        );

  factory StoryContentModel.fromJson(Map json) {
    print('🔍 StoryContentModel.fromJson - Dados: $json');
    print('🔑 Chaves no JSON: ${json.keys.toList()}');

    try {
      print('🔍 Extraindo clue_text: ${json['clue_text']}');
      print('🔍 Extraindo answer_text: ${json['answer_text']}');
      print('🔍 Extraindo title: ${json['title']}');
      print('🔍 Extraindo image_clue: ${json['image_clue']}');

      final model = StoryContentModel(
        clueText: json['clue_text'] as String,
        imageClue: json['image_clue'] as String?,
        answerText: json['answer_text'] as String,
        title: json['title'] as String,
      );
      print('✅ StoryContentModel criado com sucesso');
      print('   Título: ${model.title}');
      print('   Dica: ${model.clueText.substring(0, 50)}...');
      return model;
    } catch (e) {
      print('❌ Erro ao criar StoryContentModel: $e');
      print('   Dados recebidos: $json');
      print('   Tipo dos dados: ${json.runtimeType}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'clue_text': clueText,
      'image_clue': imageClue,
      'answer_text': answerText,
      'title': title,
    };
  }

  StoryContentModel copyWith({
    String? clueText,
    String? imageClue,
    String? answerText,
    String? title,
  }) {
    return StoryContentModel(
      clueText: clueText ?? this.clueText,
      imageClue: imageClue ?? this.imageClue,
      answerText: answerText ?? this.answerText,
      title: title ?? this.title,
    );
  }
}
