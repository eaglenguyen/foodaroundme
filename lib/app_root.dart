import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/ui/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'authentication/ui/sign_in_screen.dart';

final ValueNotifier<bool> isGuestMode = ValueNotifier(false); // for skip button

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isGuestMode,
      builder: (context, isGuest, _) {
        return StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            final session = Supabase.instance.client.auth.currentSession;

            if (session != null || isGuest) {
              return const MainScreen();
            } else {
              return const SignInScreen();
            }
          },
        );
      },
    );
  }
}
