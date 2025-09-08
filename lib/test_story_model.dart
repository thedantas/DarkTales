import 'package:darktales/data/models/story_model.dart';

/// Teste direto do StoryModel para verificar o problema
void testStoryModel() {
  print('🧪 === TESTE DO STORYMODEL (NOVA ESTRUTURA) ===');

  // Dados simulados baseados na nova estrutura
  final testData = {
    'id': 2,
    'level': 0,
    'image': 'images/002.png',
    'pt-br': {
      'clue_text':
          'Uma mulher liga para a polícia dizendo que alguém roubou seu anel. Quando a polícia chega, encontra o anel em cima da mesa. O que aconteceu?',
      'answer_text':
          'A mulher tinha sonhado que o anel havia sido roubado e pensou que era real.',
      'title': 'O Roubo do Anel… que Não Foi'
    },
    'en': {
      'clue_text':
          'A woman calls the police saying someone stole her ring. When the police arrive, they find the ring on the table. What happened?',
      'answer_text':
          'The woman had dreamed the ring was stolen and thought it was real.',
      'title': 'The Ring Theft… That Wasn\'t'
    },
    'fr': {
      'clue_text':
          'Une femme appelle la police en disant qu\'on lui a volé sa bague. Quand la police arrive, la bague est sur la table. Que s\'est-il passé ?',
      'answer_text':
          'La femme avait rêvé que sa bague avait été volée et pensait que c\'était réel.',
      'title': 'Le Vol de la Bague… Qui N\'a Pas Eu Lieu'
    }
  };

  print('📋 Dados de teste: $testData');

  try {
    final story = StoryModel.fromJson(testData);

    print('\n✅ StoryModel criado com sucesso!');
    print('   ID: ${story.id}');
    print('   Level: ${story.level} (${story.difficultyName})');
    print('   Image: ${story.image}');
    print('   Traduções: ${story.translations.length}');
    print('   Idiomas disponíveis: ${story.availableLanguages}');

    // Testar busca de conteúdo
    print('\n🔍 Testando busca de conteúdo:');
    final ptContent = story.getContentForLanguage('pt-br');
    print(
        '   pt-br: ${ptContent != null ? "✅ Encontrado" : "❌ Não encontrado"}');

    final enContent = story.getContentForLanguage('en');
    print('   en: ${enContent != null ? "✅ Encontrado" : "❌ Não encontrado"}');

    if (ptContent != null) {
      print('   Título pt-br: ${ptContent.title}');
      print('   Dica pt-br: ${ptContent.clueText.substring(0, 50)}...');
    }

    if (enContent != null) {
      print('   Título en: ${enContent.title}');
    }
  } catch (e) {
    print('❌ Erro ao criar StoryModel: $e');
  }

  print('\n🎯 === FIM DO TESTE ===');
}
