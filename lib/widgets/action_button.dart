import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class ActionButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
  });


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [


          // 🔹 Your original widget (unchanged)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.black54,
                elevation: 1,
                child: IconButton(
                  onPressed: onPressed,
                  icon: icon,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),

              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                  ),
                    color: Colors.black.withOpacity(0.35), // makes blur visible
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
                ),
              ),

              ],
          ),
        ],
      ),
    );

  }
}
