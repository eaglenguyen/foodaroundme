import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionViewModel extends ChangeNotifier {
  bool _isSubbed = false;
  bool isLoading = false;

  bool get isSubbed => _isSubbed;

  Future<void> init() async {
    await checkSubscription();
  }

  Future<void> checkSubscription() async {
    isLoading = true;
    notifyListeners();
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      debugPrint('User ID: ${customerInfo.originalAppUserId}');
      debugPrint('Aliases: ${customerInfo.allPurchasedProductIdentifiers}');


      _isSubbed = customerInfo.entitlements.active.containsKey('foodAroundMe Pro');
    } catch (e) {
      _isSubbed = false;
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
      final package = offerings.current?.lifetime;
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