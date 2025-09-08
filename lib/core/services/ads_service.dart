import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:darktales/core/services/analytics_service.dart';

class AdsService extends GetxService {
  static AdsService get to => Get.find();

  // IDs de teste do AdMob
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // IDs reais (substituir quando publicar)
  // static const String _realBannerAdUnitId =
  //     'ca-app-pub-3940256099942544/6300978111'; // TODO: Substituir
  // static const String _realInterstitialAdUnitId =
  //     'ca-app-pub-3940256099942544/1033173712'; // TODO: Substituir

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  final RxBool _isBannerAdLoaded = false.obs;
  final RxBool _isInterstitialAdLoaded = false.obs;
  final RxBool _isPremium = false.obs;

  bool get isBannerAdLoaded => _isBannerAdLoaded.value;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded.value;
  bool get isPremium => _isPremium.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAds();
    _loadPremiumStatus();
  }

  Future<void> _initializeAds() async {
    try {
      await MobileAds.instance.initialize();
      print('✅ AdMob inicializado com sucesso');

      // Carregar anúncios iniciais
      _loadBannerAd();
      _loadInterstitialAd();
    } catch (e) {
      print('❌ Erro ao inicializar AdMob: $e');
    }
  }

  void _loadPremiumStatus() {
    // O status premium será definido pelo PurchaseService
    _isPremium.value = false; // Valor inicial
  }

  // Banner Ad
  void _loadBannerAd() {
    if (_isPremium.value) return;

    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Banner ad carregado');
          _isBannerAdLoaded.value = true;
          AnalyticsService.to.logCustomEvent('banner_ad_loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad falhou ao carregar: $error');
          _isBannerAdLoaded.value = false;
          ad.dispose();
          AnalyticsService.to.logCustomEvent('banner_ad_failed',
              parameters: {'error': error.toString()});
        },
        onAdOpened: (ad) {
          AnalyticsService.to.logCustomEvent('banner_ad_opened');
        },
        onAdClosed: (ad) {
          AnalyticsService.to.logCustomEvent('banner_ad_closed');
        },
      ),
    );

    _bannerAd?.load();
  }

  BannerAd? getBannerAd() {
    if (_isPremium.value || !_isBannerAdLoaded.value) return null;
    return _bannerAd;
  }

  // Interstitial Ad
  void _loadInterstitialAd() {
    if (_isPremium.value) return;

    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad carregado');
          _interstitialAd = ad;
          _isInterstitialAdLoaded.value = true;
          AnalyticsService.to.logCustomEvent('interstitial_ad_loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial ad falhou ao carregar: $error');
          _isInterstitialAdLoaded.value = false;
          AnalyticsService.to.logCustomEvent('interstitial_ad_failed',
              parameters: {'error': error.toString()});
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_isPremium.value ||
        !_isInterstitialAdLoaded.value ||
        _interstitialAd == null) {
      onAdClosed?.call();
      return;
    }

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AnalyticsService.to.logCustomEvent('interstitial_ad_shown');
      },
      onAdDismissedFullScreenContent: (ad) {
        AnalyticsService.to.logCustomEvent('interstitial_ad_dismissed');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded.value = false;

        // Recarregar próximo anúncio
        _loadInterstitialAd();

        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Interstitial ad falhou ao mostrar: $error');
        AnalyticsService.to.logCustomEvent('interstitial_ad_show_failed',
            parameters: {'error': error.toString()});
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded.value = false;

        // Recarregar próximo anúncio
        _loadInterstitialAd();

        onAdClosed?.call();
      },
    );

    _interstitialAd?.show();
  }

  // Premium System
  void setPremiumStatus(bool isPremium) {
    _isPremium.value = isPremium;

    if (isPremium) {
      // Remover anúncios quando premium
      _bannerAd?.dispose();
      _interstitialAd?.dispose();
      _bannerAd = null;
      _interstitialAd = null;
      _isBannerAdLoaded.value = false;
      _isInterstitialAdLoaded.value = false;

      AnalyticsService.to.logCustomEvent('premium_activated');
      print('✅ Status premium ativado - anúncios removidos');
    } else {
      // Recarregar anúncios quando não premium
      _loadBannerAd();
      _loadInterstitialAd();

      AnalyticsService.to.logCustomEvent('premium_deactivated');
      print('⚠️ Status premium desativado - anúncios recarregados');
    }
  }

  // Helper methods
  String _getBannerAdUnitId() {
    return Platform.isAndroid ? _testBannerAdUnitId : _testBannerAdUnitId;
  }

  String _getInterstitialAdUnitId() {
    return Platform.isAndroid
        ? _testInterstitialAdUnitId
        : _testInterstitialAdUnitId;
  }

  @override
  void onClose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.onClose();
  }
}
