import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:darktales/core/services/ads_service.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AdsService>(
      builder: (adsService) {
        print('🔍 BannerAdWidget - isPremium: ${adsService.isPremium}');
        print(
            '🔍 BannerAdWidget - isBannerAdLoaded: ${adsService.isBannerAdLoaded}');

        // Não mostrar anúncios se for premium
        if (adsService.isPremium) {
          print('🔍 BannerAdWidget - Usuário é premium, não mostrando banner');
          return const SizedBox.shrink();
        }

        final bannerAd = adsService.getBannerAd();
        print('🔍 BannerAdWidget - bannerAd: $bannerAd');

        if (bannerAd == null) {
          print('🔍 BannerAdWidget - Banner ad é null, mostrando placeholder');
          // Mostrar um placeholder para debug
          return Container(
            width: 320,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              border: Border.all(color: Colors.blue[300]!, width: 1),
            ),
            child: const Center(
              child: Text(
                'Banner Ad Placeholder',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        print('🔍 BannerAdWidget - Mostrando banner ad real');
        return Container(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
                width: 0.5,
              ),
            ),
          ),
          child: AdWidget(ad: bannerAd),
        );
      },
    );
  }
}
