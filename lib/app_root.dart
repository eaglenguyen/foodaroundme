import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodaroundme/authentication/widgets/reset_password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'authentication/ui/sign_in_screen.dart';
import 'authentication/viewmodel/authViewModel.dart';
import 'map/ui/main_screen.dart';

final ValueNotifier<bool> isGuestMode = ValueNotifier(false); // for skip button

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}
class _AppRootState extends State<AppRoot> {
  final appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleDeepLinks();
  }

  void _handleDeepLinks() {
    // ✅ handle link when app is already open
    appLinks.uriLinkStream.listen((uri) {
      _processLink(uri);
    });

    // ✅ handle link when app is cold started from link
    appLinks.getInitialLink().then((uri) {
      if (uri != null) _processLink(uri);
    });
  }

  void _processLink(Uri uri) {
    // Supabase handles the token extraction automatically
    // just need to pass the full URI to Supabase
    Supabase.instance.client.auth.getSessionFromUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isGuestMode,
      builder: (context, isGuest, _) {
        return StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {

            if(snapshot.data?.event == AuthChangeEvent.passwordRecovery) { // what triggers this
              return const ResetPasswordScreen();
            }

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
