import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodaroundme/app_root.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../service/subscription/subscription_viewmodel.dart';
import '../util/auth_validators.dart';
import '../viewmodel/authViewModel.dart';
import '../widgets/email_view.dart';
import '../widgets/landing_view.dart';
import '../widgets/password_view.dart';


//enum vs sealed classes
enum AuthMode { signIn, signUp }
enum _AuthStep { landing, email, password }
// One route that can show 1 of 3 widgets
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  _AuthStep _step = _AuthStep.landing; // widget screens
  AuthMode _mode = AuthMode.signIn; // sign in / out screen

  final TextEditingController _emailController = TextEditingController(text: '');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToEmail() {
    setState(() {
      _step = _AuthStep.email; // Navigate widgets via setState
      _error = null;
      _loading = false;
    });
  }

  Future<void> _continueFromEmail() async {
    final email = _emailController.text.trim().toLowerCase();
    final error = validateEmail(email);

    if(error != null) {
      setState(() {
        _error = error;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;

    });

    try {
      // Your existing "does email exist" logic
      final row = await supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      final emailExists = row != null;

      if (!mounted) return;
      setState(() {
        _mode = emailExists ? AuthMode.signIn : AuthMode.signUp; //
        _step = _AuthStep.password;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not check email. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final passwordError = validatePassword(password);

    if (passwordError != null) {
      setState(() {
        _error = passwordError;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_mode == AuthMode.signIn) {
        await context.read<AuthViewModel>().signInEmail(email, password);
        // Also: if you had guest mode on, you might want:
        // isGuestMode.value = false;
      } else {
        final username = _usernameController.text.trim();
        final usernameError = validateUsername(username); // ✅ use validator
        if (usernameError != null) {
          setState(() {
            _error = usernameError;
          });
          return;
        }
        if (username.isEmpty) {
          setState(() => _error = 'Username is required.');
          return;
        }

        final res = await supabase.auth.signUp(email: email, password: password);

        // If email confirmation is enabled, session may be null.


        final user = res.user;
        if (user == null) throw Exception('Signup failed.');

        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': username, //
            }
          )
        );

        await supabase
            .from('profiles')
            .update({'username': username}) // changes username in profiles table
            .eq('id', user.id);

        // ✅ NO NAVIGATION HERE
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message
      );
    } catch (_) {
      setState(() => _error = 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgetPassword() async {
    final email = _emailController.text.trim().toLowerCase();

    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.foodaroundme://reset-password', // ✅ always mobile deep link
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

  /////////// Back Navigation Logic

  bool handleBack() {
    if (_loading) return false;

    if (_step == _AuthStep.password) {
      setState(() {
        _step = _AuthStep.email;
        _error = null;
      });
      return false;
    }
    if (_step == _AuthStep.email) {
      setState(() {
        _step = _AuthStep.landing;
        _error = null;
      });
      return false;
    }
    return true; // allow pop of the route
  }

  void _handleSystemPop(bool didPop, Object? result) {
    if (didPop) return; // system already popped

    if (_loading) return;

    if (_step == _AuthStep.password) {
      setState(() {
        _step = _AuthStep.email;
        _error = null;
      });
      return;
    }

    if (_step == _AuthStep.email) {
      setState(() {
        _step = _AuthStep.landing;
        _error = null;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final subscriptionVM = context.watch<SubscriptionViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _handleSystemPop(didPop, result);
      } ,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1C1622),
                Color(0xFF0F0B14),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: switch (_step) {
                  _AuthStep.landing => LandingView(
                    key: const ValueKey('landing'),
                    onEmailTap: _goToEmail,
                    onGoogleTap: () => authVM.signInWithGoogle(),
                    onSkipTap: () {
                      isGuestMode.value = true;
                      subscriptionVM.checkSubscription();
                    }
                  ),
                  _AuthStep.email => EmailView(
                    key: const ValueKey('email'),
                    controller: _emailController,
                    loading: _loading,
                    error: _error,
                    onBack: handleBack,
                    onContinue: _continueFromEmail,
                  ),
                  _AuthStep.password => PasswordView(
                    key: const ValueKey('password'),
                    email: _emailController.text.trim().toLowerCase(),
                    mode: _mode,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    loading: _loading,
                    error: _error,
                    onBack: handleBack,
                    onSubmit: _submitPassword,
                    onForgetPassword: _forgetPassword,
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

