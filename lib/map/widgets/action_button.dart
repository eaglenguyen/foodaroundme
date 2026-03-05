
import 'package:flutter/material.dart';

@immutable
class ActionButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool showIcon;

  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.showIcon = false,
  });


  @override
  Widget build(BuildContext context) {
    final bool iconOnly = label.isEmpty; // ✅ detect icon-only mode

    return ActionChip(
      avatar: showIcon ? icon : null,
      label:  iconOnly ? const SizedBox.shrink() : Text(label),
      onPressed: onPressed,
      backgroundColor: Colors.black87,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontWeight: FontWeight.bold,
      ),
      elevation: 3,
      labelPadding: iconOnly ? EdgeInsets.zero : null, // ✅ removes extra padding

      padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: StadiumBorder(
          side: BorderSide(
            color: Colors.blueGrey,
            width: 1.8,
          ),
    ),
    );
  }
}
