import 'package:darktales/core/services/firebase_service.dart';

/// Teste simples para verificar o problema das histórias
void main() async {
  print('🚀 Iniciando teste simples...');

  final firebaseService = FirebaseService();

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
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}
