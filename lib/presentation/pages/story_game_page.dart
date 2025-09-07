import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/data/models/story_model.dart';
import 'package:darktales/presentation/controllers/app_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';
import 'package:darktales/presentation/pages/story_solution_page.dart';

class StoryGamePage extends StatefulWidget {
  final StoryModel story;

  const StoryGamePage({
    super.key,
    required this.story,
  });

  @override
  State<StoryGamePage> createState() => _StoryGamePageState();
}

class _StoryGamePageState extends State<StoryGamePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await _fadeController.forward();
    await _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final storyController = Get.find<StoryController>();

    final content =
        widget.story.getContentForLanguage(appController.selectedLanguage);
    final isCompleted = storyController.isStoryCompleted(widget.story.id);

    if (content == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('História'),
        ),
        body: const Center(
          child: Text(
            'Conteúdo não disponível neste idioma',
            style: TextStyle(color: AppTheme.textPrimaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('História ${widget.story.id}'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          // Share button
          IconButton(
            onPressed: () => _shareStory(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Story card
                    _buildStoryCard(context, content),

                    const SizedBox(height: 24),

                    // Clue section
                    _buildClueSection(context, content),

                    const SizedBox(height: 24),

                    // Action buttons
                    _buildActionButtons(context, storyController, isCompleted),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, dynamic content) {
    final difficultyColor = _getDifficultyColor(widget.story.difficulty);
    final cardColor = _getCardColor(widget.story.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'História ${widget.story.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.story.difficulty != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyText(widget.story.difficulty!),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClueSection(BuildContext context, dynamic content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Pista',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content.clueText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    StoryController storyController,
    bool isCompleted,
  ) {
    return Column(
      children: [
        // Solution button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSolution(context),
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('Ver Solução'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Mark as completed button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _toggleCompleted(storyController, isCompleted),
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            ),
            label: Text(
              isCompleted ? 'Marcar como Incompleta' : 'Marcar como Concluída',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isCompleted
                  ? AppTheme.successColor
                  : AppTheme.textPrimaryColor,
              side: BorderSide(
                color: isCompleted
                    ? AppTheme.successColor
                    : AppTheme.textSecondaryColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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

  void _showSolution(BuildContext context) {
    Get.to(() => StorySolutionPage(story: widget.story));
  }

  void _toggleCompleted(StoryController storyController, bool isCompleted) {
    if (isCompleted) {
      storyController.markStoryAsIncomplete(widget.story.id);
      Get.snackbar(
        'História marcada como incompleta',
        'A história foi removida da lista de concluídas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.warningColor,
        colorText: AppTheme.textPrimaryColor,
      );
    } else {
      storyController.markStoryAsCompleted(widget.story.id);
      Get.snackbar(
        'História concluída!',
        'Parabéns por resolver este mistério',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor,
        colorText: AppTheme.textPrimaryColor,
      );
    }
  }

  void _shareStory() {
    // TODO: Implement share functionality
    Get.snackbar(
      'Compartilhar',
      'Funcionalidade de compartilhamento em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.accentColor,
      colorText: AppTheme.textPrimaryColor,
    );
  }
}
