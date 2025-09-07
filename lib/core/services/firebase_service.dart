// import 'package:firebase_database/firebase_database.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/data/models/story_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Get all stories
  Future<List<StoryModel>> getStories() async {
    // Mock data for demo
    return [
      StoryModel(
        id: 1,
        difficulty: 'easy',
        translations: {
          'pt-br': StoryContentModel(
            clueText:
                'Um homem entra em um bar e pede um copo de água. O garçom puxa uma arma. O homem agradece e vai embora. O que aconteceu?',
            answerText:
                'O homem tinha soluços. O garçom assustou ele com a arma, curando o soluço.',
          ),
        },
      ),
    ];
  }

  // Get story by ID
  Future<StoryModel?> getStoryById(int id) async {
    final stories = await getStories();
    try {
      return stories.firstWhere((story) => story.id == id);
    } catch (e) {
      return null;
    }
  }

  // Listen to stories changes
  Stream<List<StoryModel>> listenToStories() {
    return Stream.value([
      StoryModel(
        id: 1,
        difficulty: 'easy',
        translations: {
          'pt-br': StoryContentModel(
            clueText:
                'Um homem entra em um bar e pede um copo de água. O garçom puxa uma arma. O homem agradece e vai embora. O que aconteceu?',
            answerText:
                'O homem tinha soluços. O garçom assustou ele com a arma, curando o soluço.',
          ),
        },
      ),
    ]);
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
}
