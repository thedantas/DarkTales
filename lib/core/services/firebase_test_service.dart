import 'package:darktales/core/services/firebase_service.dart';
import 'package:darktales/data/models/story_model.dart';

class FirebaseTestService {
  static final FirebaseService _firebaseService = FirebaseService();

  // Adicionar histórias de exemplo ao Firebase
  static Future<void> addSampleStories() async {
    print('🔄 Adicionando histórias de exemplo ao Firebase...');

    // História 1 - Fácil
    final story1 = StoryModel(
      id: 1,
      difficulty: 'easy',
      category: 'classic',
      translations: {
        'pt-br': StoryContentModel(
          clueText:
              'Um homem entra em um bar e pede um copo de água. O garçom puxa uma arma. O homem agradece e vai embora. O que aconteceu?',
          answerText:
              'O homem tinha soluços. O garçom assustou ele com a arma, curando o soluço.',
        ),
        'en': StoryContentModel(
          clueText:
              'A man walks into a bar and asks for a glass of water. The bartender pulls out a gun. The man thanks him and leaves. What happened?',
          answerText:
              'The man had hiccups. The bartender scared him with the gun, curing his hiccups.',
        ),
      },
    );

    // História 2 - Médio
    final story2 = StoryModel(
      id: 2,
      difficulty: 'medium',
      category: 'mystery',
      translations: {
        'pt-br': StoryContentModel(
          clueText:
              'Uma mulher morre em um acidente de carro. Seu marido está dirigindo. Quando a polícia chega, ele não é preso. Por quê?',
          answerText:
              'A mulher estava morta antes do acidente. O marido estava dirigindo para o hospital ou funerária.',
        ),
        'en': StoryContentModel(
          clueText:
              'A woman dies in a car accident. Her husband is driving. When the police arrive, he is not arrested. Why?',
          answerText:
              'The woman was already dead before the accident. The husband was driving to the hospital or funeral home.',
        ),
      },
    );

    // História 3 - Difícil
    final story3 = StoryModel(
      id: 3,
      difficulty: 'hard',
      category: 'psychological',
      translations: {
        'pt-br': StoryContentModel(
          clueText:
              'Um homem está em uma sala sem portas ou janelas. A única coisa na sala é uma mesa. Como ele sai?',
          answerText:
              'Ele para de sonhar. Estava dormindo e sonhando com a sala.',
        ),
        'en': StoryContentModel(
          clueText:
              'A man is in a room with no doors or windows. The only thing in the room is a table. How does he get out?',
          answerText:
              'He stops dreaming. He was sleeping and dreaming about the room.',
        ),
      },
    );

    // História 4 - Fácil
    final story4 = StoryModel(
      id: 4,
      difficulty: 'easy',
      category: 'classic',
      translations: {
        'pt-br': StoryContentModel(
          clueText:
              'Um homem está dirigindo um carro preto em uma noite escura. Não há lua, nem estrelas, nem postes de luz. Um homem vestido de preto atravessa a rua. Como o motorista consegue vê-lo?',
          answerText:
              'Era dia. O homem estava dirigindo um carro preto, mas era durante o dia, não à noite.',
        ),
        'en': StoryContentModel(
          clueText:
              'A man is driving a black car on a dark night. There is no moon, no stars, no street lights. A man dressed in black crosses the street. How does the driver see him?',
          answerText:
              'It was daytime. The man was driving a black car, but it was during the day, not at night.',
        ),
      },
    );

    // História 5 - Médio
    final story5 = StoryModel(
      id: 5,
      difficulty: 'medium',
      category: 'mystery',
      translations: {
        'pt-br': StoryContentModel(
          clueText:
              'Uma mulher tem dois filhos. Um deles é médico, o outro é advogado. A mulher não é médica nem advogada. Como isso é possível?',
          answerText:
              'Os filhos são homens. A mulher é a mãe deles, não uma colega de profissão.',
        ),
        'en': StoryContentModel(
          clueText:
              'A woman has two sons. One is a doctor, the other is a lawyer. The woman is neither a doctor nor a lawyer. How is this possible?',
          answerText:
              'The sons are men. The woman is their mother, not a professional colleague.',
        ),
      },
    );

    try {
      await _firebaseService.addStory(story1);
      print('✅ História 1 adicionada');

      await _firebaseService.addStory(story2);
      print('✅ História 2 adicionada');

      await _firebaseService.addStory(story3);
      print('✅ História 3 adicionada');

      await _firebaseService.addStory(story4);
      print('✅ História 4 adicionada');

      await _firebaseService.addStory(story5);
      print('✅ História 5 adicionada');

      print('🎉 Todas as histórias de exemplo foram adicionadas com sucesso!');
    } catch (e) {
      print('❌ Erro ao adicionar histórias: $e');
    }
  }

  // Testar conexão com Firebase
  static Future<void> testConnection() async {
    print('🔄 Testando conexão com Firebase...');

    try {
      final stories = await _firebaseService.getStories();
      print('✅ Conexão estabelecida! Encontradas ${stories.length} histórias');

      if (stories.isNotEmpty) {
        print('📚 Primeira história encontrada:');
        final firstStory = stories.first;
        print('   ID: ${firstStory.id}');
        print('   Dificuldade: ${firstStory.difficulty}');
        print('   Categoria: ${firstStory.category}');
        print('   Idiomas disponíveis: ${firstStory.availableLanguages}');

        if (firstStory.translations.containsKey('pt-br')) {
          final content = firstStory.translations['pt-br']!;
          print('   Dica: ${content.clueText}');
        }
      }
    } catch (e) {
      print('❌ Erro na conexão: $e');
    }
  }

  // Limpar todas as histórias (para testes)
  static Future<void> clearAllStories() async {
    print('🔄 Limpando todas as histórias...');

    try {
      final stories = await _firebaseService.getStories();
      for (final story in stories) {
        await _firebaseService.deleteStory(story.id);
        print('🗑️ História ${story.id} removida');
      }
      print('✅ Todas as histórias foram removidas');
    } catch (e) {
      print('❌ Erro ao limpar histórias: $e');
    }
  }
}
