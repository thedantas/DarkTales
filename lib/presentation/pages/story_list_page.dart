import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/data/models/story_model.dart';
import 'package:darktales/presentation/controllers/app_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';
import 'package:darktales/presentation/pages/story_game_page.dart';

class StoryListPage extends StatelessWidget {
  final String? difficulty;
  final String? title;

  const StoryListPage({
    super.key,
    this.difficulty,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final storyController = Get.find<StoryController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title ?? 'Todas as Histórias'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context, storyController),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Obx(() {
        if (storyController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          );
        }

        final stories = difficulty != null
            ? storyController.getStoriesByDifficulty(difficulty!)
            : storyController.filteredStories;

        if (stories.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            final isCompleted = storyController.isStoryCompleted(story.id);

            return _buildStoryCard(
              context,
              story,
              isCompleted,
              () => _openStory(context, story),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma história encontrada',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(
    BuildContext context,
    StoryModel story,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    final difficultyColor = _getDifficultyColor(story.difficulty);
    final cardColor = _getCardColor(story.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Story icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  // Story title
                  Text(
                    _getStoryTitle(story),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Difficulty
                  if (story.difficulty != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyText(story.difficulty!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                ],
              ),
            ),

            // Completed indicator
            if (isCompleted)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // Difficulty ribbon
            if (story.difficulty != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 0,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: difficultyColor,
                        width: 20,
                      ),
                      left: BorderSide(
                        color: difficultyColor,
                        width: 20,
                      ),
                      right: BorderSide(
                        color: Colors.transparent,
                        width: 20,
                      ),
                      bottom: BorderSide(
                        color: Colors.transparent,
                        width: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case AppConstants.difficultyEasy:
        return AppTheme.easyColor;
      case AppConstants.difficultyNormal:
        return AppTheme.normalColor;
      case AppConstants.difficultyHard:
        return AppTheme.hardColor;
      default:
        return AppTheme.accentColor;
    }
  }

  Color _getCardColor(int storyId) {
    return AppTheme.cardColors[storyId % AppTheme.cardColors.length];
  }

  String _getStoryTitle(StoryModel story) {
    final appController = Get.find<AppController>();
    final content = story.getContentForLanguage(appController.selectedLanguage);
    if (content != null) {
      // Extract title from clue text (first sentence or first few words)
      final words = content.clueText.split(' ');
      if (words.length > 6) {
        return '${words.take(6).join(' ')}...';
      }
      return content.clueText;
    }
    return 'História ${story.id}';
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case AppConstants.difficultyEasy:
        return 'Fácil';
      case AppConstants.difficultyNormal:
        return 'Normal';
      case AppConstants.difficultyHard:
        return 'Difícil';
      default:
        return difficulty;
    }
  }

  void _openStory(BuildContext context, StoryModel story) {
    Get.to(() => StoryGamePage(story: story));
  }

  void _showFilterDialog(
      BuildContext context, StoryController storyController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Filtrar Histórias',
          style: TextStyle(color: AppTheme.textPrimaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Difficulty filter
            const Text(
              'Dificuldade:',
              style: TextStyle(color: AppTheme.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                    'Todas', '', storyController.selectedDifficulty),
                _buildFilterChip('Fácil', AppConstants.difficultyEasy,
                    storyController.selectedDifficulty),
                _buildFilterChip('Normal', AppConstants.difficultyNormal,
                    storyController.selectedDifficulty),
                _buildFilterChip('Difícil', AppConstants.difficultyHard,
                    storyController.selectedDifficulty),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              storyController.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final storyController = Get.find<StoryController>();
        if (selected) {
          storyController.filterStories(difficulty: value);
        } else {
          storyController.clearFilters();
        }
      },
      selectedColor: AppTheme.accentColor.withOpacity(0.3),
      checkmarkColor: AppTheme.accentColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentColor : AppTheme.textPrimaryColor,
      ),
    );
  }
}
