import 'package:flutter/material.dart';


class Sliders extends StatelessWidget {

  final double value;
  final ValueChanged<double> onChanged;


  const Sliders({
    super.key,
    required this.value,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    const double min = 600;
    const double max = 1600;

    final percent = ((value - min) / (max - min)).clamp(0.0, 1.0);

    final walkColor = Color.lerp(Colors.black, Colors.grey, percent)!;
    final carColor = Color.lerp(Colors.grey, Colors.black, percent)!;

    return Material(
      elevation: 6,
      color: Colors.white70,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.directions_walk,
                    size: 20,
                    color: walkColor,
                  ),
                ),

                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: value.clamp(min, max),
                      min: min,
                      max: max,
                      divisions: 10,
                      onChanged: onChanged,
                      activeColor: Colors.blueGrey,
                      inactiveColor: Colors.grey,
                    ),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.directions_car,
                    size: 20,
                    color: carColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}