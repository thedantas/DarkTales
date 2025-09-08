import 'package:get/get.dart';
import 'package:darktales/presentation/controllers/language_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';

/// Debug para investigar problemas de idioma
class LanguageDebugger {
  static Future<void> debugLanguageIssue() async {
    print('🔍 === DEBUG DE IDIOMA ===');

    final languageController = Get.find<LanguageController>();
    final storyController = Get.find<StoryController>();

    // 1. Verificar idioma atual
    print('🌍 Idioma atual: ${languageController.currentLanguage}');
    print('🌍 Nome do idioma: ${languageController.getCurrentLanguageName()}');

    // 2. Verificar histórias carregadas
    final stories = storyController.stories;
    print('📚 Total de histórias: ${stories.length}');

    if (stories.isNotEmpty) {
      final firstStory = stories.first;
      print('\n📖 Primeira história:');
      print('   ID: ${firstStory.id}');
      print('   Level: ${firstStory.level}');
      print('   Dificuldade: ${firstStory.difficulty}');
      print('   Categoria: ${firstStory.category}');
      print('   Image: ${firstStory.image}');
      print('   Idiomas disponíveis: ${firstStory.availableLanguages}');

      // 3. Verificar conteúdo no idioma atual
      final currentLanguage = languageController.currentLanguage;
      print('\n🔍 Verificando idioma: $currentLanguage');

      if (firstStory.translations.containsKey(currentLanguage)) {
        print('✅ História tem conteúdo em $currentLanguage');
        final content = firstStory.getContentForLanguage(currentLanguage);
        if (content != null) {
          print('✅ Conteúdo encontrado:');
          print('   Dica: ${content.clueText.substring(0, 50)}...');
          print('   Resposta: ${content.answerText.substring(0, 50)}...');
        } else {
          print('❌ Conteúdo é null');
        }
      } else {
        print('❌ História NÃO tem conteúdo em $currentLanguage');
        print(
            '   Idiomas disponíveis: ${firstStory.translations.keys.toList()}');
      }

      // 4. Verificar método do controller
      print('\n🔧 Testando método do controller:');
      final hasContent =
          storyController.hasContentInCurrentLanguage(firstStory);
      print('   hasContentInCurrentLanguage: $hasContent');

      final content =
          storyController.getStoryContentInCurrentLanguage(firstStory);
      print(
          '   getStoryContentInCurrentLanguage: ${content != null ? "✅ Encontrado" : "❌ Null"}');

      if (content != null) {
        print('   Tipo do conteúdo: ${content.runtimeType}');
      }
    } else {
      print('❌ Nenhuma história carregada');
    }

    // 5. Verificar idiomas suportados
    print('\n🌐 Idiomas suportados:');
    for (final lang in languageController.supportedLanguages) {
      print('   ${lang.key}: ${lang.value}');
    }

    // 6. Testar filtros de dificuldade
    print('\n🔍 Testando filtros de dificuldade:');
    final easyStories = storyController.getStoriesByDifficulty('easy');
    final normalStories = storyController.getStoriesByDifficulty('normal');
    final hardStories = storyController.getStoriesByDifficulty('hard');

    print('   Fácil (easy): ${easyStories.length} histórias');
    print('   Normal (normal): ${normalStories.length} histórias');
    print('   Difícil (hard): ${hardStories.length} histórias');

    // 7. Mostrar todas as histórias com seus níveis
    print('\n📋 Todas as histórias:');
    for (final story in stories) {
      print(
          '   História ${story.id}: level=${story.level}, difficulty="${story.difficulty}"');
    }

    print('\n🎯 === FIM DO DEBUG ===');
  }
}
