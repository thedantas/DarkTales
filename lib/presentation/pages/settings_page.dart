import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/presentation/controllers/language_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';
import 'package:darktales/presentation/pages/language_selection_page.dart';
import 'package:darktales/presentation/pages/premium_page.dart';
import 'package:darktales/core/services/purchase_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Seção de Idioma
          _buildSection(
            context,
            title: 'Idioma',
            children: [
              Obx(() => _buildLanguageTile(
                    languageController: languageController,
                    onTap: () => _openLanguageSelection(),
                  )),
            ],
          ),

          const SizedBox(height: 24),

          // Seção Premium
          _buildSection(
            context,
            title: 'Premium',
            children: [
              Obx(() => _buildPremiumTile()),
            ],
          ),

          const SizedBox(height: 24),

          // Seção de Aplicativo
          _buildSection(
            context,
            title: 'Aplicativo',
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Sobre',
                subtitle: 'Versão 1.0.0',
                onTap: () => _showAboutDialog(),
              ),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Ajuda',
                subtitle: 'Como jogar',
                onTap: () => _showHelpDialog(),
              ),
              _buildSettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Debug',
                subtitle: 'Testar Firebase',
                onTap: () => _openDebugPage(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção de Dados
          _buildSection(
            context,
            title: 'Dados',
            children: [
              _buildSettingsTile(
                icon: Icons.refresh,
                title: 'Recarregar Histórias',
                subtitle: 'Buscar atualizações',
                onTap: () => _refreshStories(),
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Limpar Cache',
                subtitle: 'Remover dados temporários',
                onTap: () => _clearCache(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                color: AppTheme.accentColor,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppTheme.surfaceColor,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumTile() {
    final purchaseService = Get.find<PurchaseService>();

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.star,
          color: Colors.white,
        ),
      ),
      title: Text(
        purchaseService.isPremium
            ? 'DarkTales Premium'
            : 'Upgrade para Premium',
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        purchaseService.isPremium
            ? 'Você tem acesso completo'
            : 'Remova anúncios e desbloqueie tudo',
        style: const TextStyle(
          color: AppTheme.textSecondaryColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (purchaseService.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ATIVO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
        ],
      ),
      onTap: () => Get.to(() => const PremiumPage()),
    );
  }

  Widget _buildLanguageTile({
    required LanguageController languageController,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.language,
          color: AppTheme.accentColor,
        ),
      ),
      title: const Text(
        'Idioma',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        languageController.getCurrentLanguageName(),
        style: const TextStyle(
          color: AppTheme.textSecondaryColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondaryColor,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondaryColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondaryColor,
      ),
      onTap: onTap,
    );
  }

  void _openLanguageSelection() {
    Get.to(() => const LanguageSelectionPage(isFirstTime: false));
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Sobre o Dark Tales',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: const Text(
          'Dark Tales é um jogo de histórias sombrias onde você precisa descobrir o que realmente aconteceu.\n\n'
          'Versão: 1.0.0\n'
          'Desenvolvido com Flutter e Firebase.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Fechar',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Como Jogar',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: const Text(
          '1. Escolha uma história\n'
          '2. Leia a dica cuidadosamente\n'
          '3. Tente descobrir o que aconteceu\n'
          '4. Revele a resposta quando estiver pronto\n\n'
          'Dica: Pense fora da caixa! As histórias têm explicações inesperadas.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Entendi',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  void _openDebugPage() {
    // Importar e navegar para a página de debug
    // Get.to(() => const TestFirebaseWidget());
    Get.snackbar(
      'Debug',
      'Página de debug em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _refreshStories() {
    // Recarregar histórias
    Get.find<StoryController>().refreshStories();
    Get.snackbar(
      'Sucesso',
      'Histórias recarregadas',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _clearCache() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Limpar Cache',
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        content: const Text(
          'Tem certeza que deseja limpar o cache? Isso removerá dados temporários.',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Implementar limpeza de cache
              Get.snackbar(
                'Sucesso',
                'Cache limpo',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Limpar',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
