import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/core/services/analytics_service.dart';
import 'package:darktales/data/models/story_model.dart';
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
  String? _cachedImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // Inicia timer para medir tempo gasto na história
    AnalyticsService.to.startTimer();
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
    final storyController = Get.find<StoryController>();

    final content =
        storyController.getStoryContentInCurrentLanguage(widget.story);
    final isCompleted = storyController.isStoryCompleted(widget.story.id);

    if (content == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(_getStoryTitle()),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.language,
                size: 80,
                color: AppTheme.accentColor.withOpacity(0.5),
              ),
              const SizedBox(height: 20),
              Text(
                'Conteúdo não disponível',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta história não está disponível no idioma selecionado.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_getStoryTitle()),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          // Share button
          IconButton(
            onPressed: () => _shareStory(context),
            icon: const Icon(Icons.share),
          ),
        ],
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottom: null,
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
        children: [],
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
          Text(
            content.clueText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 20),
          // Story image
          if (widget.story.image.isNotEmpty)
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _getImageUrl(widget.story.image),
                    fit: BoxFit.cover,
                    cacheManager:
                        null, // Desabilita o cache para evitar erro de banco readonly
                    placeholder: (context, url) => Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('🖼️ Erro ao carregar imagem: $error');
                      print('🖼️ URL da imagem: $url');
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
            onPressed: () =>
                _toggleCompleted(storyController, isCompleted, context),
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
    // Log da visualização da solução
    final storyController = Get.find<StoryController>();
    final content =
        storyController.getStoryContentInCurrentLanguage(widget.story);
    final title = content?.title ?? 'História ${widget.story.id}';

    AnalyticsService.to.logSolutionViewed(
      widget.story.id,
      title,
    );

    Get.to(() => StorySolutionPage(story: widget.story));
  }

  void _toggleCompleted(
      StoryController storyController, bool isCompleted, BuildContext context) {
    if (isCompleted) {
      storyController.markStoryAsIncomplete(widget.story.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('História marcada como incompleta'),
          backgroundColor: AppTheme.warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      storyController.markStoryAsCompleted(widget.story.id);

      // Log da conclusão da história
      final timeSpent = AnalyticsService.to.getElapsedTime() ?? 0;
      final content =
          storyController.getStoryContentInCurrentLanguage(widget.story);
      final title = content?.title ?? 'História ${widget.story.id}';

      AnalyticsService.to.logStoryCompleted(
        widget.story.id,
        title,
        widget.story.level,
        timeSpent,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'História concluída! Parabéns por resolver este mistério'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareStory(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Funcionalidade de compartilhamento em desenvolvimento'),
        backgroundColor: AppTheme.accentColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStoryTitle() {
    final storyController = Get.find<StoryController>();
    final content =
        storyController.getStoryContentInCurrentLanguage(widget.story);
    if (content != null && content.title != null) {
      return content.title;
    }
    return 'História ${widget.story.id}';
  }

  String _getImageUrl(String imagePath) {
    // Se a imagem já é uma URL completa, retorna ela
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Usa cache se disponível
    if (_cachedImageUrl != null) {
      return _cachedImageUrl!;
    }

    // Constrói a URL do Firebase Storage
    // Baseado no exemplo: https://firebasestorage.googleapis.com/v0/b/dark-tales-e67d1.firebasestorage.app/o/id_1.png?alt=media&token=...
    final bucket = 'dark-tales-e67d1.firebasestorage.app';
    final encodedPath = Uri.encodeComponent(imagePath);
    final url =
        'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';

    // Cacheia a URL
    _cachedImageUrl = url;
    return url;
  }
}
