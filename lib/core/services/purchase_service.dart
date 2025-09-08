import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darktales/core/services/analytics_service.dart';
import 'package:darktales/core/services/ads_service.dart';

class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // IDs dos produtos (substituir pelos IDs reais da App Store/Google Play)
  static const String _premiumProductId = 'darktales_premium_monthly';

  final RxBool _isAvailable = false.obs;
  final RxBool _isLoading = false.obs;
  final RxList<ProductDetails> _products = <ProductDetails>[].obs;
  final RxBool _isPremium = false.obs;

  bool get isAvailable => _isAvailable.value;
  bool get isLoading => _isLoading.value;
  List<ProductDetails> get products => _products;
  bool get isPremium => _isPremium.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializePurchase();
    await _loadPremiumStatus();
  }

  Future<void> _initializePurchase() async {
    try {
      _isAvailable.value = await _inAppPurchase.isAvailable();

      if (_isAvailable.value) {
        _subscription = _inAppPurchase.purchaseStream.listen(
          _onPurchaseUpdate,
          onDone: () => _subscription.cancel(),
          onError: (error) {
            print('❌ Erro no stream de compras: $error');
            AnalyticsService.to.logCustomEvent('purchase_stream_error',
                parameters: {'error': error.toString()});
          },
        );

        await _loadProducts();
        print('✅ Serviço de compras inicializado');
      } else {
        print('❌ Compras in-app não disponíveis');
      }
    } catch (e) {
      print('❌ Erro ao inicializar compras: $e');
      AnalyticsService.to.logCustomEvent('purchase_init_error',
          parameters: {'error': e.toString()});
    }
  }

  Future<void> _loadProducts() async {
    if (!_isAvailable.value) return;

    try {
      _isLoading.value = true;

      const Set<String> productIds = {
        _premiumProductId,
      };

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('❌ Produtos não encontrados: ${response.notFoundIDs}');
      }

      _products.value = response.productDetails;
      print('✅ Produtos carregados: ${_products.length}');

      AnalyticsService.to.logCustomEvent('products_loaded', parameters: {
        'count': _products.length,
        'products': _products.map((p) => p.id).toList(),
      });
    } catch (e) {
      print('❌ Erro ao carregar produtos: $e');
      AnalyticsService.to.logCustomEvent('load_products_error',
          parameters: {'error': e.toString()});
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium.value = prefs.getBool('is_premium') ?? false;

      // Atualizar status no AdsService
      AdsService.to.setPremiumStatus(_isPremium.value);

      print('✅ Status premium carregado: ${_isPremium.value}');
    } catch (e) {
      print('❌ Erro ao carregar status premium: $e');
    }
  }

  Future<void> _savePremiumStatus(bool isPremium) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', isPremium);
      _isPremium.value = isPremium;

      // Atualizar status no AdsService
      AdsService.to.setPremiumStatus(isPremium);

      print('✅ Status premium salvo: $isPremium');
    } catch (e) {
      print('❌ Erro ao salvar status premium: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('⏳ Compra pendente: ${purchaseDetails.productID}');
          AnalyticsService.to.logCustomEvent('purchase_pending', parameters: {
            'product_id': purchaseDetails.productID,
          });
          break;

        case PurchaseStatus.purchased:
          print('✅ Compra realizada: ${purchaseDetails.productID}');

          // Verificar se é produto premium
          if (_isPremiumProduct(purchaseDetails.productID)) {
            await _savePremiumStatus(true);
            AnalyticsService.to
                .logCustomEvent('premium_purchased', parameters: {
              'product_id': purchaseDetails.productID,
              'transaction_id': purchaseDetails.purchaseID,
            });
          }

          // Finalizar compra
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.error:
          print('❌ Erro na compra: ${purchaseDetails.error}');
          AnalyticsService.to.logCustomEvent('purchase_error',
              parameters: {'error': purchaseDetails.error.toString()});
          break;

        case PurchaseStatus.restored:
          print('🔄 Compra restaurada: ${purchaseDetails.productID}');

          // Verificar se é produto premium
          if (_isPremiumProduct(purchaseDetails.productID)) {
            await _savePremiumStatus(true);
            AnalyticsService.to.logCustomEvent('premium_restored', parameters: {
              'product_id': purchaseDetails.productID,
            });
          }

          // Finalizar compra
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.canceled:
          print('❌ Compra cancelada: ${purchaseDetails.productID}');
          AnalyticsService.to.logCustomEvent('purchase_canceled', parameters: {
            'product_id': purchaseDetails.productID,
          });
          break;
      }
    } catch (e) {
      print('❌ Erro ao processar compra: $e');
      AnalyticsService.to.logCustomEvent('handle_purchase_error',
          parameters: {'error': e.toString()});
    }
  }

  bool _isPremiumProduct(String productId) {
    return productId == _premiumProductId;
  }

  Future<bool> purchasePremium() async {
    if (!_isAvailable.value || _products.isEmpty) {
      print('❌ Compras não disponíveis ou produtos não carregados');
      return false;
    }

    try {
      // Usar o primeiro produto disponível (pode ser Android ou iOS)
      final ProductDetails productDetails = _products.first;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success =
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (success) {
        AnalyticsService.to.logCustomEvent('purchase_initiated', parameters: {
          'product_id': productDetails.id,
          'price': productDetails.price,
          'currency': productDetails.currencyCode,
        });
        print('✅ Compra iniciada: ${productDetails.id}');
      } else {
        print('❌ Falha ao iniciar compra');
        AnalyticsService.to.logCustomEvent('purchase_init_failed', parameters: {
          'product_id': productDetails.id,
        });
      }

      return success;
    } catch (e) {
      print('❌ Erro ao iniciar compra: $e');
      AnalyticsService.to.logCustomEvent('purchase_init_error',
          parameters: {'error': e.toString()});
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isAvailable.value) {
      print('❌ Compras não disponíveis');
      return false;
    }

    try {
      await _inAppPurchase.restorePurchases();
      AnalyticsService.to.logCustomEvent('restore_purchases_initiated');
      print('✅ Restauração de compras iniciada');
      return true;
    } catch (e) {
      print('❌ Erro ao restaurar compras: $e');
      AnalyticsService.to.logCustomEvent('restore_purchases_error',
          parameters: {'error': e.toString()});
      return false;
    }
  }

  ProductDetails? getPremiumProduct() {
    return _products
        .firstWhereOrNull((product) => _isPremiumProduct(product.id));
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
