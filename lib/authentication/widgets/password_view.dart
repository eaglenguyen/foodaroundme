import 'package:flutter/material.dart';
import 'package:foodaroundme/authentication/widgets/input_pill.dart';

import '../ui/sign_in_screen.dart';



class PasswordView extends StatelessWidget {

  final String email;
  final AuthMode mode;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool loading;
  final String? error;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onForgetPassword;


  const PasswordView({
    super.key,
    required this.email,
    required this.mode,
    required this.usernameController,
    required this.passwordController,
    required this.loading,
    required this.error,
    required this.onBack,
    required this.onSubmit,
    required this.onForgetPassword,
  });


  @override
  Widget build(BuildContext context) {
    final isSignUp = mode == AuthMode.signUp;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(-8, 0),
            child: IconButton(
              onPressed: loading ? null : onBack,
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            isSignUp ? 'Create account' : 'Welcome back',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(email, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 22),

          if (isSignUp) ...[
            InputPill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'john617',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          InputPill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),

          if (!isSignUp) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: loading ? null : () => onForgetPassword(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: const Color(0xFFF5C518),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          if (error != null)
            Text(error!, style: const TextStyle(color: Color(0xFFFF6B6B))),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : () => onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5C518),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  isSignUp ? 'Create account' : 'Sign in',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}