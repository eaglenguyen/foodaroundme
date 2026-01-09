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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.secondary,
            elevation: 4,
            child: IconButton(
              onPressed: onPressed,
              icon: icon,
              color: theme.colorScheme.onSecondary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
