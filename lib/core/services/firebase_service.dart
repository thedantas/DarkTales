import 'package:firebase_database/firebase_database.dart';
import 'package:darktales/data/models/story_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _storiesRef =
      FirebaseDatabase.instance.ref('stories');

  // Get all stories
  Future<List<StoryModel>> getStories() async {
    try {
      final snapshot = await _storiesRef.get();

      if (!snapshot.exists) {
        // Se não há dados, retorna lista vazia
        return [];
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      final List<StoryModel> stories = [];

      print('📊 Dados brutos encontrados: ${data.keys.length} entradas');
      print('🔑 Chaves: ${data.keys.toList()}');

      data.forEach((key, value) {
        print('\n🔍 Processando chave: $key (tipo: ${key.runtimeType})');

        if (value is Map<dynamic, dynamic>) {
          try {
            final storyData = Map<String, dynamic>.from(value);
            print('📋 Dados da história: $storyData');

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
    } catch (e) {
      print('Erro ao buscar histórias: $e');
      return [];
    }
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

      final Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      final List<StoryModel> stories = [];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          try {
            final storyData = Map<String, dynamic>.from(value);
            stories.add(StoryModel.fromJson(storyData));
          } catch (e) {
            print('Erro ao converter história $key: $e');
          }
        }
      });

      return stories;
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

      final data = snapshot.value as Map<dynamic, dynamic>;
      final ids =
          data.keys.map((key) => int.tryParse(key.toString()) ?? 0).toList();
      return (ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b)) + 1;
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
