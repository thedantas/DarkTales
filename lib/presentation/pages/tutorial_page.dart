import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/presentation/controllers/app_controller.dart';
import 'package:darktales/presentation/pages/home_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Como jogar (1/4)',
      icon: Icons.groups,
      description:
          'Dark Tales deve ser jogado em grupo.\n\nUma pessoa, designada como narradora, escolhe um enigma e lê sua descrição em voz alta.',
    ),
    TutorialStep(
      title: 'Como jogar (2/4)',
      icon: Icons.chat_bubble_outline,
      description:
          'Depois, o narrador lê sua solução sem dizer às outras pessoas. Os outros jogadores deverão fazer perguntas para resolver o enigma. O narrador só pode responder às perguntas usando "Sim", "Não" ou "Não é relevante".',
    ),
    TutorialStep(
      title: 'Como jogar (3/4)',
      icon: Icons.search,
      description:
          'A única solução possível é aquela fornecida na parte de trás de cada carta enigma. Se a resposta ainda não for suficientemente clara, os jogadores devem seguir a interpretação do narrador do enigma.\n\nCabe ao narrador dar algumas pistas se a história estiver em um impasse.',
    ),
    TutorialStep(
      title: 'Como jogar (4/4)',
      icon: Icons.extension,
      description: 'O nível de dificuldade das histórias é indicado por cores.',
      showDifficultyColors: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeTutorial() {
    final appController = Get.find<AppController>();
    appController.setTutorialCompleted();
    appController.setFirstLaunchCompleted();
    Get.off(() => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  _totalPages,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < _totalPages - 1 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.accentColor
                            : AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialStep(_tutorialSteps[index]);
                },
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.textPrimaryColor,
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  // Next/Complete button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.textPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1 ? 'FECHAR' : 'PRÓXIMO',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: AppTheme.textPrimaryColor,
            ),
          ),

          const SizedBox(height: 40),

          // Description
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),

          // Difficulty colors (only for last step)
          if (step.showDifficultyColors) ...[
            const SizedBox(height: 40),
            _buildDifficultyColors(),
          ],
        ],
      ),
    );
  }

  Widget _buildDifficultyColors() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDifficultyCard(
              color: AppTheme.easyColor,
              label: 'Fácil',
            ),
            _buildDifficultyCard(
              color: AppTheme.normalColor,
              label: 'Normal',
            ),
            _buildDifficultyCard(
              color: AppTheme.hardColor,
              label: 'Difícil',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.textPrimaryColor,
              width: 2,
            ),
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
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class TutorialStep {
  final String title;
  final IconData icon;
  final String description;
  final bool showDifficultyColors;

  TutorialStep({
    required this.title,
    required this.icon,
    required this.description,
    this.showDifficultyColors = false,
  });
}
