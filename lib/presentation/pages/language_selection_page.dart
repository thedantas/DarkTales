import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/presentation/controllers/language_controller.dart';
import 'package:darktales/presentation/pages/home_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  final bool isFirstTime;

  const LanguageSelectionPage({
    super.key,
    this.isFirstTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Header
              if (isFirstTime) ...[
                const SizedBox(height: 40),
                Icon(
                  Icons.language,
                  size: 80,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo ao Dark Tales',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        color: AppTheme.primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Escolha seu idioma preferido',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
              ] else ...[
                const SizedBox(height: 20),
                Text(
                  'Selecionar Idioma',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 20),
              ],

              // Lista de idiomas
              Expanded(
                child: Obx(() {
                  if (languageController.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                      ),
                    );
                  }

                  // Força a observação do currentLanguage
                  final currentLang = languageController.currentLanguage;

                  return ListView.builder(
                    itemCount: languageController.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final language =
                          languageController.supportedLanguages[index];
                      final languageCode = language.key;
                      final languageName = language.value;
                      final isSelected =
                          languageController.isLanguageSelected(languageCode);

                      // Debug log
                      if (isSelected) {
                        print('🎯 Idioma $languageCode está selecionado');
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isSelected
                            ? AppTheme.accentColor.withOpacity(0.1)
                            : AppTheme.surfaceColor,
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _getLanguageFlag(languageCode),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          title: Text(
                            languageName,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.accentColor
                                          : AppTheme.primaryColor,
                                    ),
                          ),
                          subtitle: Text(
                            _getLanguageDescription(languageCode),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppTheme.accentColor,
                                )
                              : null,
                          onTap: () =>
                              _selectLanguage(languageController, languageCode),
                        ),
                      );
                    },
                  );
                }),
              ),

              // Botões
              if (isFirstTime) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _continueToApp(languageController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continuar',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveAndClose(languageController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectLanguage(LanguageController controller, String languageCode) {
    print('🔄 Selecionando idioma: $languageCode');
    print('🔄 Idioma atual antes: ${controller.currentLanguage}');
    controller.setCurrentLanguage(languageCode);
    print('🔄 Idioma atual depois: ${controller.currentLanguage}');
  }

  void _continueToApp(LanguageController controller) {
    Get.offAll(() => const HomePage());
  }

  void _saveAndClose(LanguageController controller) async {
    print('💾 Salvando idioma selecionado: ${controller.currentLanguage}');

    if (controller.currentLanguage.isNotEmpty) {
      print('✅ Idioma válido encontrado, salvando...');
      await controller.changeLanguage(controller.currentLanguage);
      print('✅ Idioma salvo com sucesso!');

      // Recarregar o idioma para garantir que está sincronizado
      await controller.reloadLanguage();
      print('🔄 Idioma recarregado após salvamento');

      Get.back();
    } else {
      print('⚠️ Nenhum idioma selecionado, usando inglês como padrão');
      // Se nenhum idioma foi selecionado, usar inglês como padrão
      await controller.changeLanguage('en');
      await controller.reloadLanguage();
      Get.back();
    }
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'pt-br':
        return '🇧🇷';
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'ja':
        return '🇯🇵';
      case 'ru':
        return '🇷🇺';
      default:
        return '🌍';
    }
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'pt-br':
        return 'Idioma detectado do seu dispositivo';
      case 'en':
        return 'English language';
      case 'es':
        return 'Idioma español';
      case 'fr':
        return 'Langue française';
      case 'de':
        return 'Deutsche Sprache';
      case 'it':
        return 'Lingua italiana';
      case 'ja':
        return '日本語';
      case 'ru':
        return 'Русский язык';
      default:
        return 'Language';
    }
  }
}
