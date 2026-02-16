import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/ui/main_screen.dart';

import 'authentication/ui/sign_in_screen.dart';


final authState = ValueNotifier<bool>(false);

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authState,
      builder: (_, isLoggedIn, __) {
        return isLoggedIn
            ? const MainScreen()
            : const SignInScreen();
      },
    );
  }
}
