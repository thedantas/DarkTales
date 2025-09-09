import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:darktales/core/theme/app_theme.dart';
import 'package:darktales/core/constants/app_constants.dart';
import 'package:darktales/presentation/controllers/app_controller.dart';
import 'package:darktales/presentation/controllers/story_controller.dart';
import 'package:darktales/presentation/controllers/language_controller.dart';
import 'package:darktales/core/services/analytics_service.dart';
import 'package:darktales/core/services/ads_service.dart';
import 'package:darktales/core/services/purchase_service.dart';
import 'package:darktales/core/services/storage_service.dart';
import 'package:darktales/presentation/pages/splash_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  await StorageService().init();
  Get.put(AnalyticsService());
  Get.put(AdsService());
  Get.put(PurchaseService());

  // Initialize controllers
  Get.put(AppController());
  Get.put(LanguageController());
  Get.put(StoryController());

  runApp(const DarkTalesApp());
}

class DarkTalesApp extends StatelessWidget {
  const DarkTalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: AppConstants.pageTransitionDuration,
      // Adiciona observer do Analytics para rastreamento automático de navegação
      navigatorObservers: [AnalyticsService.to.observer],
    );
  }
}
