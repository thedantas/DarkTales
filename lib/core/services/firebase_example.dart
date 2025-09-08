import 'package:darktales/core/services/firebase_service.dart';
import 'package:darktales/core/services/firebase_test_service.dart';
import 'package:darktales/data/models/story_model.dart';

/// Exemplo de como usar o FirebaseService
/// Este arquivo demonstra todas as operações disponíveis
class FirebaseExample {
  static final FirebaseService _firebaseService = FirebaseService();

  /// Exemplo completo de uso do Firebase
  static Future<void> runExample() async {
    print('🚀 Iniciando exemplo de uso do Firebase...\n');

    // 1. Testar conexão
    await FirebaseTestService.testConnection();
    print('');

    // 2. Adicionar histórias de exemplo (se não existirem)
    final existingStories = await _firebaseService.getStories();
    if (existingStories.isEmpty) {
      await FirebaseTestService.addSampleStories();
      print('');
    }

    // 3. Buscar todas as histórias
    print('📚 Buscando todas as histórias...');
    final allStories = await _firebaseService.getStories();
    print('Encontradas ${allStories.length} histórias\n');

    // 4. Buscar história por ID
    print('🔍 Buscando história por ID...');
    final storyById = await _firebaseService.getStoryById(1);
    if (storyById != null) {
      print('História encontrada: ${storyById.id} - ${storyById.difficulty}');
    }
    print('');

    // 5. Buscar histórias por dificuldade
    print('🎯 Buscando histórias fáceis...');
    final easyStories = await _firebaseService.getStoriesByDifficulty('easy');
    print('Encontradas ${easyStories.length} histórias fáceis\n');

    // 6. Buscar histórias por idioma
    print('🌍 Buscando histórias em português...');
    final ptStories = await _firebaseService.getStoriesByLanguage('pt-br');
    print('Encontradas ${ptStories.length} histórias em português\n');

    // 7. Criar nova história
    print('➕ Criando nova história...');
    final newStory = StoryModel(
      id: 999,
      difficulty: 'easy',
      category: 'test',
      translations: {
        'pt-br': StoryContentModel(
          clueText: 'Esta é uma história de teste. O que é isso?',
          answerText:
              'É apenas um teste para verificar se o Firebase está funcionando!',
        ),
      },
    );

    final success = await _firebaseService.addStory(newStory);
    if (success) {
      print('✅ Nova história criada com sucesso!');
    } else {
      print('❌ Erro ao criar nova história');
    }
    print('');

    // 8. Atualizar história
    print('✏️ Atualizando história...');
    final updatedStory = newStory.copyWith(
      difficulty: 'medium',
      category: 'updated_test',
    );

    final updateSuccess = await _firebaseService.updateStory(updatedStory);
    if (updateSuccess) {
      print('✅ História atualizada com sucesso!');
    } else {
      print('❌ Erro ao atualizar história');
    }
    print('');

    // 9. Deletar história de teste
    print('🗑️ Removendo história de teste...');
    final deleteSuccess = await _firebaseService.deleteStory(999);
    if (deleteSuccess) {
      print('✅ História de teste removida!');
    } else {
      print('❌ Erro ao remover história');
    }
    print('');

    // 10. Obter próximo ID disponível
    print('🔢 Obtendo próximo ID disponível...');
    final nextId = await _firebaseService.getNextStoryId();
    print('Próximo ID disponível: $nextId\n');

    // 11. Exemplo de stream (listener em tempo real)
    print('📡 Configurando listener em tempo real...');
    print('(Este stream ficará ativo por 5 segundos para demonstração)');

    final stream = _firebaseService.listenToStories();
    final subscription = stream.listen(
      (stories) {
        print('📊 Stream atualizado: ${stories.length} histórias');
      },
      onError: (error) {
        print('❌ Erro no stream: $error');
      },
    );

    // Aguardar 5 segundos para demonstrar o stream
    await Future.delayed(const Duration(seconds: 5));
    await subscription.cancel();
    print('');

    print('🎉 Exemplo concluído com sucesso!');
  }

  /// Exemplo de como usar streams para atualizações em tempo real
  static void setupRealTimeListener() {
    print('📡 Configurando listener em tempo real...');

    final stream = _firebaseService.listenToStories();
    stream.listen(
      (stories) {
        print('🔄 Histórias atualizadas: ${stories.length} encontradas');

        // Aqui você pode atualizar a UI quando os dados mudarem
        // Por exemplo, atualizar uma lista de histórias
        for (final story in stories) {
          print('   📖 História ${story.id}: ${story.difficulty}');
        }
      },
      onError: (error) {
        print('❌ Erro no listener: $error');
      },
    );
  }

  /// Exemplo de como buscar uma história específica em tempo real
  static void setupStoryListener(int storyId) {
    print('📡 Configurando listener para história $storyId...');

    final stream = _firebaseService.listenToStory(storyId);
    stream.listen(
      (story) {
        if (story != null) {
          print('🔄 História $storyId atualizada:');
          print('   Dificuldade: ${story.difficulty}');
          print('   Categoria: ${story.category}');
        } else {
          print('🗑️ História $storyId foi removida');
        }
      },
      onError: (error) {
        print('❌ Erro no listener da história: $error');
      },
    );
  }
}
