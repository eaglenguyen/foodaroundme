import 'package:flutter/material.dart';



class DragHandleArrow extends StatelessWidget {
  final Color color;

  const DragHandleArrow({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: Stack(
        children: const [
          Positioned(left: 0, child: _ArrowStroke(angle: -0.4)),
          Positioned(right: 0, child: _ArrowStroke(angle: 0.4)),
        ],
      ),
    );
  }
}

class _ArrowStroke extends StatelessWidget {
  final double angle;

  const _ArrowStroke({required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 19,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
