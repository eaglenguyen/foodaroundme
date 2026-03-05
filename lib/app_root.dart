import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'authentication/ui/sign_in_screen.dart';
import 'authentication/viewmodel/authViewModel.dart';
import 'map/ui/main_screen.dart';

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
              context.read<AuthViewModel>().loadProfileTable();
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
