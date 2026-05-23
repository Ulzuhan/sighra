import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IapService {
  IapService._privateConstructor() {
    _initIap();
  }
  static final IapService instance = IapService._privateConstructor();

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  void _initIap() {
    try {
      final purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint("IAP Purchase Stream Error: $error"),
      );
      _checkAvailability();
    } catch (e) {
      debugPrint("IAP Init Exception: $e. Running defensively.");
    }
  }

  Future<void> _checkAvailability() async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (_isAvailable) {
        await loadProducts();
      }
    } catch (e) {
      debugPrint("IAP checkAvailability exception: $e");
    }
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;
    try {
      const Set<String> ids = {
        'respiro_espresso_tip',
        'respiro_lotus_tip',
        'respiro_zen_sponsor',
      };
      final response = await _iap.queryProductDetails(ids);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("IAP Products not found on store: ${response.notFoundIDs}");
      }
      _products = response.productDetails;
      debugPrint("IAP Loaded products: ${_products.length}");
    } catch (e) {
      debugPrint("IAP loadProducts exception: $e");
    }
  }

  Future<void> buyProduct(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint("IAP buyProduct exception: $e");
      rethrow;
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint("IAP Purchase Pending: ${purchaseDetails.productID}");
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint("IAP Purchase Error: ${purchaseDetails.error}");
        _completePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        debugPrint("IAP Purchase Approved: ${purchaseDetails.productID}");
        _completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _iap.completePurchase(purchaseDetails);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
