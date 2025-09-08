import 'package:darktales/data/models/story_model.dart';

/// Teste específico para verificar o problema com os dados do Firebase
void testFirebaseData() {
  print('🧪 === TESTE DE DADOS DO FIREBASE ===');

  // Dados exatos como você mostrou no Firebase
  final firebaseData = {
    "stories": [
      {
        "id": 1,
        "level": 1,
        "image": "images/001.png",
        "pt-br": {
          "clue_text":
              "Um homem entra em um bar e pede um copo de água. O garçom puxa uma arma. O homem agradece e vai embora. O que aconteceu?",
          "answer_text":
              "O homem tinha soluços. O garçom assustou ele com a arma, curando o soluço.",
          "title": "Soluço no Bar"
        },
        "en": {
          "clue_text":
              "A man enters a bar and asks for a glass of water. The bartender pulls out a gun. The man thanks him and leaves. What happened?",
          "answer_text":
              "The man had hiccups. The bartender scared him with the gun, curing the hiccups.",
          "title": "Hiccups at the Bar"
        }
      },
      {
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
      }
    ]
  };

  print('📋 Dados do Firebase: $firebaseData');

  // Testar processamento de cada história
  final stories = firebaseData['stories'] as List;
  print('\n📊 Processando ${stories.length} histórias...');

  for (int i = 0; i < stories.length; i++) {
    print('\n🔍 === PROCESSANDO HISTÓRIA ${i + 1} ===');
    final storyData = stories[i] as Map<String, dynamic>;

    try {
      final story = StoryModel.fromJson(storyData);

      print('✅ História ${story.id} criada com sucesso!');
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
      print('❌ Erro ao processar história ${i + 1}: $e');
      print('   Dados: $storyData');
    }
  }

  print('\n🎯 === FIM DO TESTE ===');
}
