import 'package:flutter/material.dart';

import 'input_pill.dart';


class EmailView extends StatelessWidget {
  const EmailView({
    super.key,
    required this.controller,
    required this.loading,
    required this.error,
    required this.onBack,
    required this.onContinue,
  });

  final TextEditingController controller;
  final bool loading;
  final String? error;
  final VoidCallback onBack;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test this
          IconButton(
            onPressed: loading ? null : onBack,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54, // background color
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Sign in or sign up',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter your email to get started.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 22),

          InputPill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'example@gmail.com',
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (error != null)
            Text(error!, style: const TextStyle(color: Color(0xFFFF6B6B))),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : () => onContinue(),
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
                    : const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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