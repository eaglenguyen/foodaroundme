import 'package:flutter/material.dart';

class MorphingDragHandle extends StatelessWidget {
  final double sheetSize;

  const MorphingDragHandle({
    super.key,
    required this.sheetSize,
  });

  @override
  Widget build(BuildContext context) {
    final targetAngle = _arrowAngle(sheetSize);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetAngle),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      builder: (context, angle, _) {
        return SizedBox(
          width: 36,
          height: 16,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: _ArrowStroke(angle: -angle),
              ),
              Positioned(
                right: 0,
                child: _ArrowStroke(angle: angle),
              ),
            ],
          ),
        );
      },
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
        width: 20,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// LERP formula , lerp(a, b, t) = a + (b - a) * t, a = 0.6, b = 0.0, t = percentage/progress between a & b
double _arrowAngle(double size) {
  const double maxAngle = 0.6; // arrow angle
  const double collapseStart = 0.155;
  const double collapseEnd = 0.80;

  if (size <= collapseStart) return maxAngle; // full arrow
  if (size >= collapseEnd) return 0.0; // line

  final t = (collapseEnd - size) / (collapseEnd - collapseStart); // linear interpolation, remaining distance / total distance
  return maxAngle * t; // converts into an angle
}