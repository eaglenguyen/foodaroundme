import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionViewModel extends ChangeNotifier {
  bool _isPro = false;
  bool isLoading = true;

  bool get isPro => _isPro;

  Future<void> init() async {
    await checkSubscription();
  }

  Future<void> checkSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('Active entitlements: ${customerInfo.entitlements.active}');

      _isPro = customerInfo.entitlements.active.containsKey('foodAroundMe Pro');
    } catch (e) {
      _isPro = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchase() async {
    try {
      isLoading = true;
      notifyListeners();

      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.availablePackages.first;
      if (package == null) return;

      await Purchases.purchase(
        PurchaseParams.package(package),
      );
      await checkSubscription(); // ✅ refresh after purchase
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError) {
        rethrow;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    try {
      isLoading = true;
      notifyListeners();
      await Purchases.restorePurchases();
      await checkSubscription();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}