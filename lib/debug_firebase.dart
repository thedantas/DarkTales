import 'package:firebase_database/firebase_database.dart';
import 'package:darktales/core/services/firebase_service.dart';
import 'package:darktales/data/models/story_model.dart';

/// Classe para debug do Firebase - investigar problemas de dados
class FirebaseDebugger {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final DatabaseReference _storiesRef = _database.ref('stories');

  /// Debug completo - mostra toda a estrutura dos dados
  static Future<void> debugCompleteStructure() async {
    print('🔍 === DEBUG COMPLETO DO FIREBASE ===');

    try {
      final snapshot = await _storiesRef.get();

      if (!snapshot.exists) {
        print('❌ Nenhum dado encontrado no Firebase');
        return;
      }

      print('✅ Dados encontrados no Firebase!');
      print('📊 Estrutura completa:');
      print(snapshot.value);
      print('');

      // Analisar cada história individualmente
      final data = snapshot.value as Map<dynamic, dynamic>;
      print('📚 Análise individual das histórias:');

      data.forEach((key, value) {
        print('\n--- História $key ---');
        print('Tipo da chave: ${key.runtimeType}');
        print('Tipo do valor: ${value.runtimeType}');

        if (value is Map<dynamic, dynamic>) {
          print('Campos disponíveis: ${value.keys.toList()}');

          // Verificar campos obrigatórios
          if (value.containsKey('id')) {
            print('✅ ID encontrado: ${value['id']}');
          } else {
            print('❌ ID não encontrado');
          }

          if (value.containsKey('difficulty')) {
            print('✅ Dificuldade encontrada: ${value['difficulty']}');
          } else {
            print('❌ Dificuldade não encontrada');
          }

          if (value.containsKey('category')) {
            print('✅ Categoria encontrada: ${value['category']}');
          } else {
            print('❌ Categoria não encontrada');
          }

          // Verificar traduções
          final translationKeys = value.keys
              .where((k) => k != 'id' && k != 'difficulty' && k != 'category')
              .toList();
          print('🌍 Idiomas disponíveis: $translationKeys');

          for (final lang in translationKeys) {
            final translation = value[lang];
            if (translation is Map<dynamic, dynamic>) {
              print('  $lang: ${translation.keys.toList()}');
            }
          }
        } else {
          print('❌ Valor não é um Map: $value');
        }
      });
    } catch (e) {
      print('❌ Erro ao acessar Firebase: $e');
    }
  }

  /// Testar o FirebaseService atual
  static Future<void> testFirebaseService() async {
    print('🧪 === TESTE DO FIREBASE SERVICE ===');

    final firebaseService = FirebaseService();

    try {
      print('📥 Buscando todas as histórias...');
      final stories = await firebaseService.getStories();
      print('✅ Histórias encontradas: ${stories.length}');

      for (int i = 0; i < stories.length; i++) {
        final story = stories[i];
        print('\n--- História ${i + 1} ---');
        print('ID: ${story.id}');
        print('Dificuldade: ${story.difficulty}');
        print('Categoria: ${story.category}');
        print('Idiomas: ${story.availableLanguages}');

        if (story.translations.containsKey('pt-br')) {
          final content = story.translations['pt-br']!;
          print('Dica (pt-br): ${content.clueText.substring(0, 50)}...');
        }
      }
    } catch (e) {
      print('❌ Erro no FirebaseService: $e');
    }
  }

  /// Testar parsing individual de cada história
  static Future<void> testIndividualParsing() async {
    print('🔬 === TESTE DE PARSING INDIVIDUAL ===');

    try {
      final snapshot = await _storiesRef.get();

      if (!snapshot.exists) {
        print('❌ Nenhum dado encontrado');
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) async {
        print('\n--- Testando História $key ---');

        try {
          if (value is Map<dynamic, dynamic>) {
            final storyData = Map<String, dynamic>.from(value);
            print('📋 Dados brutos: $storyData');

            final story = StoryModel.fromJson(storyData);
            print('✅ Parsing bem-sucedido!');
            print('   ID: ${story.id}');
            print('   Dificuldade: ${story.difficulty}');
            print('   Categoria: ${story.category}');
            print('   Idiomas: ${story.availableLanguages}');
          } else {
            print('❌ Valor não é um Map: $value');
          }
        } catch (e) {
          print('❌ Erro no parsing da história $key: $e');
          print('   Dados problemáticos: $value');
        }
      });
    } catch (e) {
      print('❌ Erro geral: $e');
    }
  }

  /// Comparar dados brutos vs dados processados
  static Future<void> compareRawVsProcessed() async {
    print('⚖️ === COMPARAÇÃO: DADOS BRUTOS vs PROCESSADOS ===');

    try {
      // Dados brutos
      print('📥 Obtendo dados brutos...');
      final snapshot = await _storiesRef.get();
      final rawData = snapshot.value;
      print('Dados brutos: $rawData');

      // Dados processados
      print('\n📤 Obtendo dados processados...');
      final firebaseService = FirebaseService();
      final processedStories = await firebaseService.getStories();
      print('Histórias processadas: ${processedStories.length}');

      // Comparação
      if (rawData is Map<dynamic, dynamic>) {
        print('\n📊 Comparação:');
        print('Dados brutos - número de chaves: ${rawData.keys.length}');
        print(
            'Dados processados - número de histórias: ${processedStories.length}');

        if (rawData.keys.length != processedStories.length) {
          print('⚠️ DISCREPÂNCIA ENCONTRADA!');
          print('Chaves brutas: ${rawData.keys.toList()}');
          print(
              'IDs processados: ${processedStories.map((s) => s.id).toList()}');
        } else {
          print('✅ Números coincidem');
        }
      }
    } catch (e) {
      print('❌ Erro na comparação: $e');
    }
  }

  /// Executar todos os testes de debug
  static Future<void> runAllTests() async {
    print('🚀 === INICIANDO TODOS OS TESTES DE DEBUG ===\n');

    await debugCompleteStructure();
    print('\n' + '=' * 50 + '\n');

    await testFirebaseService();
    print('\n' + '=' * 50 + '\n');

    await testIndividualParsing();
    print('\n' + '=' * 50 + '\n');

    await compareRawVsProcessed();

    print('\n🎉 === TESTES DE DEBUG CONCLUÍDOS ===');
  }
}
