import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/core/services/analytics_service.dart';
import 'package:darktales/presentation/controllers/app_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';
import 'package:darktales/presentation/pages/story_list_page.dart';
import 'package:darktales/presentation/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final storyController = Get.find<StoryController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          // Settings
          IconButton(
            onPressed: () {
              AnalyticsService.to.logSettingsOpened();
              Get.to(() => const SettingsPage());
            },
            icon: const Icon(Icons.settings),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _buildWelcomeSection(appController),

              const SizedBox(height: 24),

              // Quick stats
              _buildStatsSection(storyController, context),

              const SizedBox(height: 24),

              // Difficulty sections
              _buildDifficultySection(
                context,
                'Fácil',
                AppTheme.easyColor,
                AppConstants.difficultyEasy,
                storyController,
              ),

              const SizedBox(height: 16),

              _buildDifficultySection(
                context,
                'Normal',
                AppTheme.normalColor,
                AppConstants.difficultyNormal,
                storyController,
              ),

              const SizedBox(height: 16),

              _buildDifficultySection(
                context,
                'Difícil',
                AppTheme.hardColor,
                AppConstants.difficultyHard,
                storyController,
              ),

              const SizedBox(height: 24),

              // All stories button
              _buildAllStoriesButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection(AppController appController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(0.1),
            AppTheme.accentColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) => Text(
              'Bem-vindo ao Dark Tales',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) => Text(
              'Escolha uma história e desafie seus amigos a descobrir o mistério!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      StoryController storyController, BuildContext context) {
    final totalStories = storyController.stories.length;
    final completedStories = storyController.completedStories.length;
    final completionRate =
        totalStories > 0 ? (completedStories / totalStories * 100).round() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total de Histórias',
            totalStories.toString(),
            Icons.auto_stories,
            AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Concluídas',
            completedStories.toString(),
            Icons.check_circle,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Progresso',
            '$completionRate%',
            Icons.trending_up,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(
    BuildContext context,
    String title,
    Color color,
    String difficulty,
    StoryController storyController,
  ) {
    final stories = storyController.getStoriesByDifficulty(difficulty);
    final completedCount = stories
        .where((story) => storyController.isStoryCompleted(story.id))
        .length;

    return GestureDetector(
      onTap: () => Get.to(() => StoryListPage(
            difficulty: difficulty,
            title: title,
          )),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Difficulty indicator
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stories.length} histórias • $completedCount concluídas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllStoriesButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          AnalyticsService.to.logPageView('story_list', parameters: {
            'source': 'home_button',
          });
          Get.to(() => const StoryListPage());
        },
        icon: const Icon(Icons.list),
        label: const Text('Ver Todas as Histórias'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.textPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
