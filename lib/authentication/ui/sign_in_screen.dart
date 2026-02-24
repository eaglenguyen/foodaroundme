import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodaroundme/app_root.dart';
import 'package:foodaroundme/authentication/ui/email_screen.dart';
import 'package:foodaroundme/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../viewmodel/authViewModel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  StreamSubscription<AuthState>? _authSub;


  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        authState.value = true;
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AppRoot(),
          ),
        );
      }
    });
  }


  // For future use
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    _authSub?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1622), // dark purple/black
              Color(0xFF0F0B14), // darker
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),

                // Title
                const Center(
                  child: Text(
                    'FoodAroundMe',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Bottom card section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1422),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign in or sign up',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose a method to continue.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone (primary)
                      _AuthButtonDark(
                        icon: Icons.email,
                        label: 'Sign in with Email',
                        variant: _AuthButtonVariant.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmailScreen(),
                            )
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Google
                      _AuthButtonDark(
                        icon: Icons.g_mobiledata_outlined,
                        label: 'Sign in with Google',
                        variant: _AuthButtonVariant.secondary,
                        onTap: () {
                          authVM.signInWithGoogle();
                        },
                      ),

                      const SizedBox(height: 8),

                      // Optional Email (kept for future but styled)
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Skip
                Center(
                  child: TextButton(
                    onPressed: () {
                      authState.value = true;
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



enum _AuthButtonVariant { primary, secondary }

class _AuthButtonDark extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _AuthButtonVariant variant;

  const _AuthButtonDark({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == _AuthButtonVariant.primary;

    final Color bgColor = isPrimary
        ? const Color(0xFFF5C518) // yellow primary
        : const Color(0xFF241C2E); // dark input-like

    final Color fgColor = isPrimary ? Colors.black : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}