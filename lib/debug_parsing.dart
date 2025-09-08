import 'package:darktales/data/models/story_model.dart';

/// Debug específico para investigar o problema de parsing
void debugParsing() {
  print('🔍 === DEBUG DE PARSING ===');

  // Dados exatos como você mostrou
  final storyData = {
    "id": 2,
    "level": 0,
    "image": "images/002.png",
    "pt-br": {
      "clue_text":
          "Uma mulher liga para a polícia dizendo que alguém roubou seu anel. Quando a polícia chega, encontra o anel em cima da mesa. O que aconteceu?",
      "answer_text":
          "A mulher tinha sonhado que o anel havia sido roubado e pensou que era real.",
      "title": "O Roubo do Anel… que Não Foi"
    },
    "en": {
      "clue_text":
          "A woman calls the police saying someone stole her ring. When the police arrive, they find the ring on the table. What happened?",
      "answer_text":
          "The woman had dreamed the ring was stolen and thought it was real.",
      "title": "The Ring Theft… That Wasn't"
    }
  };

  print('📋 Dados de entrada: $storyData');
  print('🔑 Chaves: ${storyData.keys.toList()}');

  // Testar parsing manual
  print('\n🔍 Testando parsing manual...');

  final translations = <String, StoryContentModel>{};

  storyData.forEach((key, value) {
    print('🔍 Chave: $key, Valor: $value, Tipo: ${value.runtimeType}');

    if (key != 'id' &&
        key != 'level' &&
        key != 'image' &&
        value is Map<String, dynamic>) {
      print('✅ Processando tradução: $key');
      try {
        final content = StoryContentModel.fromJson(value);
        translations[key] = content;
        print('✅ Tradução $key criada: ${content.title}');
      } catch (e) {
        print('❌ Erro ao criar tradução $key: $e');
      }
    } else {
      print('⏭️ Pulando chave $key');
    }
  });

  print('\n📊 Resultado:');
  print('   Traduções criadas: ${translations.length}');
  print('   Idiomas: ${translations.keys.toList()}');

  // Testar StoryModel.fromJson
  print('\n🔍 Testando StoryModel.fromJson...');
  try {
    final story = StoryModel.fromJson(storyData);
    print('✅ StoryModel criado com sucesso!');
    print('   ID: ${story.id}');
    print('   Level: ${story.level}');
    print('   Image: ${story.image}');
    print('   Traduções: ${story.translations.length}');
    print('   Idiomas disponíveis: ${story.availableLanguages}');

    // Testar busca de conteúdo
    final ptContent = story.getContentForLanguage('pt-br');
    print(
        '   Conteúdo pt-br: ${ptContent != null ? "✅ Encontrado" : "❌ Não encontrado"}');

    if (ptContent != null) {
      print('   Título: ${ptContent.title}');
      print('   Dica: ${ptContent.clueText.substring(0, 50)}...');
    }
  } catch (e) {
    print('❌ Erro ao criar StoryModel: $e');
  }

  print('\n🎯 === FIM DO DEBUG ===');
}
