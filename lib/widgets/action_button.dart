
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
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Colors.black87,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontWeight: FontWeight.bold,
      ),
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.black54,
            width: 1.8,
          ),
    ),
    );
  }
}
