import 'package:flutter/material.dart';

import '../../app_root.dart';


class PaywallScreen extends StatelessWidget {
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const PaywallScreen({
    super.key,
    required this.onPurchase,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_rounded, size: 64, color: Colors.black54),
              const SizedBox(height: 24),
              const Text(
                'Search is a Pro feature',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Subscribe to search any restaurant, cafe, or bar near you.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
          ValueListenableBuilder<bool>(
            valueListenable: isGuestMode,
            builder: (context, isGuest, _) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isGuest ? null : onPurchase, // ✅ disable if guest
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Subscribe — 4.99/mo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: isGuest ? null : onRestore,
                    child: const Text(
                      'Restore purchases',
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ],
              );
            },
          )
            ],
          ),
        ),
      ),
    );
  }
}
