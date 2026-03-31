import 'package:purchases_flutter/purchases_flutter.dart';

import '../../main.dart';

class RevenueCatService {
  bool _configured = false;

  Future<void> init() async {
    if(_configured) return;

    await Purchases.setLogLevel(LogLevel.debug);

    await Purchases.configure(
      PurchasesConfiguration('test_FgGjtcDHcSGCgniFhddvdYPPlss'),
    );

    _configured = true;


    supabase.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user;

      if (user != null) {
        await Purchases.logIn(user.id);
      } else {
        await Purchases.logOut();
      }
    });
  }
}