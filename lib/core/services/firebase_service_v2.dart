import 'package:firebase_database/firebase_database.dart';
import 'package:darktales/data/models/story_model.dart';

/// Versão melhorada do FirebaseService com melhor tratamento de dados
class FirebaseServiceV2 {
  static final FirebaseServiceV2 _instance = FirebaseServiceV2._internal();
  factory FirebaseServiceV2() => _instance;
  FirebaseServiceV2._internal();

  final DatabaseReference _storiesRef =
      FirebaseDatabase.instance.ref('stories');

  // Get all stories with improved error handling
  Future<List<StoryModel>> getStories() async {
    try {
      print('🔍 Buscando histórias no Firebase...');
      final snapshot = await _storiesRef.get();

      if (!snapshot.exists) {
        print('📭 Nenhum dado encontrado no Firebase');
        return [];
      }

      final data = snapshot.value;
      print('📊 Tipo dos dados: ${data.runtimeType}');
      print('📊 Dados brutos: $data');

      if (data is Map<dynamic, dynamic>) {
        // Verificar se é a nova estrutura com array de stories
        if (data.containsKey('stories') && data['stories'] is List) {
          print('🆕 Detectada nova estrutura com array de stories');
          return _processStoriesFromArray(data['stories'] as List<dynamic>);
        } else {
          // Estrutura legacy (Map direto)
          return _processStoriesFromMap(data);
        }
      } else if (data is List) {
        return _processStoriesFromList(data);
      } else {
        print('❌ Formato de dados não reconhecido: ${data.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar histórias: $e');
      return [];
    }
  }

  // Process stories from Map format
  List<StoryModel> _processStoriesFromMap(Map<dynamic, dynamic> data) {
    final List<StoryModel> stories = [];

    print('📊 Processando ${data.keys.length} entradas do tipo Map');
    print('🔑 Chaves: ${data.keys.toList()}');

    data.forEach((key, value) {
      print('\n🔍 Processando chave: $key (tipo: ${key.runtimeType})');

      if (value is Map<dynamic, dynamic>) {
        try {
          final storyData = Map<String, dynamic>.from(value);
          print('📋 Dados da história: $storyData');

          // Verificar se tem os campos obrigatórios
          if (!storyData.containsKey('id')) {
            print('⚠️ História sem ID, usando chave como ID: $key');
            storyData['id'] = int.tryParse(key.toString()) ?? 0;
          }

          final story = StoryModel.fromJson(storyData);
          stories.add(story);
          print('✅ História ${story.id} adicionada com sucesso');
        } catch (e) {
          print('❌ Erro ao converter história $key: $e');
          print('   Dados problemáticos: $value');
        }
      } else {
        print('❌ Valor não é um Map para chave $key: $value');
      }
    });

    print('📚 Total de histórias processadas: ${stories.length}');
    return stories;
  }

  // Process stories from List format
  List<StoryModel> _processStoriesFromList(List data) {
    final List<StoryModel> stories = [];

    print('📊 Processando ${data.length} entradas do tipo List');

    for (int i = 0; i < data.length; i++) {
      final value = data[i];
      print('\n🔍 Processando índice: $i');

      if (value is Map<dynamic, dynamic>) {
        try {
          final storyData = Map<String, dynamic>.from(value);
          print('📋 Dados da história: $storyData');

          // Verificar se tem ID, senão usar o índice
          if (!storyData.containsKey('id')) {
            print('⚠️ História sem ID, usando índice como ID: $i');
            storyData['id'] = i + 1;
          }

          final story = StoryModel.fromJson(storyData);
          stories.add(story);
          print('✅ História ${story.id} adicionada com sucesso');
        } catch (e) {
          print('❌ Erro ao converter história no índice $i: $e');
          print('   Dados problemáticos: $value');
        }
      } else {
        print('❌ Valor não é um Map no índice $i: $value');
      }
    }

    print('📚 Total de histórias processadas: ${stories.length}');
    return stories;
  }

  // Process stories from Array format (new structure)
  List<StoryModel> _processStoriesFromArray(List<dynamic> data) {
    final List<StoryModel> stories = [];

    print(
        '📊 Processando ${data.length} histórias do tipo Array (nova estrutura)');

    for (int i = 0; i < data.length; i++) {
      print('\n🔍 Processando índice: $i');

      if (data[i] is Map<dynamic, dynamic>) {
        try {
          final storyData = Map<String, dynamic>.from(data[i]);
          print('📋 Dados da história: $storyData');

          final story = StoryModel.fromJson(storyData);
          stories.add(story);
          print('✅ História ${story.id} adicionada com sucesso');
        } catch (e) {
          print('❌ Erro ao converter história no índice $i: $e');
          print('   Dados problemáticos: ${data[i]}');
        }
      } else {
        print(
            '⚠️ Item não é um Map: ${data[i]} (tipo: ${data[i].runtimeType})');
      }
    }

    print('📚 Total de histórias processadas: ${stories.length}');
    return stories;
  }

  // Get story by ID
  Future<StoryModel?> getStoryById(int id) async {
    try {
      final snapshot = await _storiesRef.child(id.toString()).get();

      if (!snapshot.exists) {
        return null;
      }

      final data =
          Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
      return StoryModel.fromJson(data);
    } catch (e) {
      print('Erro ao buscar história por ID $id: $e');
      return null;
    }
  }

  // Listen to stories changes
  Stream<List<StoryModel>> listenToStories() {
    return _storiesRef.onValue.map((event) {
      if (!event.snapshot.exists) {
        return <StoryModel>[];
      }

      final data = event.snapshot.value;

      if (data is Map<dynamic, dynamic>) {
        return _processStoriesFromMap(data);
      } else if (data is List) {
        return _processStoriesFromList(data);
      } else {
        return <StoryModel>[];
      }
    });
  }

  // Get stories by language
  Future<List<StoryModel>> getStoriesByLanguage(String languageCode) async {
    final stories = await getStories();
    return stories
        .where((story) => story.translations.containsKey(languageCode))
        .toList();
  }

  // Get stories by difficulty
  Future<List<StoryModel>> getStoriesByDifficulty(String difficulty) async {
    final stories = await getStories();
    return stories.where((story) => story.difficulty == difficulty).toList();
  }

  // Add new story
  Future<bool> addStory(StoryModel story) async {
    try {
      await _storiesRef.child(story.id.toString()).set(story.toJson());
      return true;
    } catch (e) {
      print('Erro ao adicionar história: $e');
      return false;
    }
  }

  // Update existing story
  Future<bool> updateStory(StoryModel story) async {
    try {
      await _storiesRef.child(story.id.toString()).update(story.toJson());
      return true;
    } catch (e) {
      print('Erro ao atualizar história: $e');
      return false;
    }
  }

  // Delete story
  Future<bool> deleteStory(int storyId) async {
    try {
      await _storiesRef.child(storyId.toString()).remove();
      return true;
    } catch (e) {
      print('Erro ao deletar história: $e');
      return false;
    }
  }

  // Get next available ID
  Future<int> getNextStoryId() async {
    try {
      final snapshot = await _storiesRef.get();
      if (!snapshot.exists) {
        return 1;
      }

      final data = snapshot.value;
      if (data is Map<dynamic, dynamic>) {
        final ids =
            data.keys.map((key) => int.tryParse(key.toString()) ?? 0).toList();
        return (ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b)) + 1;
      } else if (data is List) {
        return data.length + 1;
      }
      return 1;
    } catch (e) {
      print('Erro ao obter próximo ID: $e');
      return 1;
    }
  }

  // Listen to specific story changes
  Stream<StoryModel?> listenToStory(int storyId) {
    return _storiesRef.child(storyId.toString()).onValue.map((event) {
      if (!event.snapshot.exists) {
        return null;
      }

      try {
        final data = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        return StoryModel.fromJson(data);
      } catch (e) {
        print('Erro ao converter história $storyId: $e');
        return null;
      }
    });
  }
}
