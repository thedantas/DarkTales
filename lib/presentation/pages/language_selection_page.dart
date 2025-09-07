import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/presentation/controllers/app_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final storyController = Get.find<StoryController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Idioma'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          itemCount: AppConstants.supportedLanguages.length,
          itemBuilder: (context, index) {
            final languageCode = AppConstants.supportedLanguages[index];
            final isSelected = appController.selectedLanguage == languageCode;
            final storiesCount =
                storyController.getStoriesByLanguage(languageCode).length;

            return _buildLanguageTile(
              context,
              languageCode,
              appController.getLanguageName(languageCode),
              storiesCount,
              isSelected,
              () => _selectLanguage(appController, languageCode),
            );
          },
        );
      }),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String languageCode,
    String languageName,
    int storiesCount,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentColor.withOpacity(0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? AppTheme.accentColor : AppTheme.secondaryColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textSecondaryColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Language name
                Expanded(
                  child: Text(
                    languageName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimaryColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                ),

                // Stories count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentColor.withOpacity(0.2)
                        : AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$storiesCount ${_getStoriesText(storiesCount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppTheme.accentColor
                              : AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStoriesText(int count) {
    if (count == 1) return 'história';
    return 'histórias';
  }

  void _selectLanguage(AppController appController, String languageCode) {
    appController.setSelectedLanguage(languageCode);
    Get.back();

    // Show confirmation
    Get.snackbar(
      'Idioma alterado',
      'O idioma foi alterado para ${appController.getLanguageName(languageCode)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.accentColor,
      colorText: AppTheme.textPrimaryColor,
      duration: const Duration(seconds: 2),
    );
  }
}
