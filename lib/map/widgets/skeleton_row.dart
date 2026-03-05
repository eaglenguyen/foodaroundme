

import 'package:flutter/material.dart';

class ShimmerPlaceRow extends StatelessWidget {
  const ShimmerPlaceRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// LEFT IMAGE SKELETON
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.white24,
              ),
            ),

            const SizedBox(width: 12),

            /// CENTER TEXT SKELETON
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonLine(width: 80),
                  const SizedBox(height: 6),
                  _skeletonLine(width: 120),
                  const SizedBox(height: 6),
                  _skeletonLine(width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonLine({required double width}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}


