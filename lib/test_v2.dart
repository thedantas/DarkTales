import 'package:darktales/core/services/firebase_service_v2.dart';

/// Teste da versão 2 do FirebaseService
void main() async {
  print('🚀 Testando FirebaseServiceV2...');

  final firebaseService = FirebaseServiceV2();

  try {
    print('📥 Buscando histórias...');
    final stories = await firebaseService.getStories();

    print('\n📊 RESULTADO:');
    print('Histórias encontradas: ${stories.length}');

    for (int i = 0; i < stories.length; i++) {
      final story = stories[i];
      print('\n--- História ${i + 1} ---');
      print('ID: ${story.id}');
      print('Dificuldade: ${story.difficulty}');
      print('Categoria: ${story.category}');
      print('Idiomas: ${story.availableLanguages}');

      if (story.translations.containsKey('pt-br')) {
        final content = story.translations['pt-br']!;
        print('Dica: ${content.clueText.substring(0, 50)}...');
      }
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}
