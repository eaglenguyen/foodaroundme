import 'package:flutter/cupertino.dart';



class DragHandleLine extends StatelessWidget {
  final Color color;

  const DragHandleLine({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
