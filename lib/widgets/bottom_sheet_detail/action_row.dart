import 'package:flutter/material.dart';

import '../../model/place.dart';



class ActionRow extends StatelessWidget {
  final Place place;

  const ActionRow({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ActionChip(
            icon: Icons.directions,
            label: "Directions",
            onTap: () {
              // open maps
            },
          ),
          _ActionChip(
            icon: Icons.language,
            label: "Website",
          ),
          _ActionChip(
            icon: Icons.call,
            label: "Call",
          ),
          _ActionChip(
            icon: Icons.share,
            label: "Share",
            onTap: () {
              // share place
            },
          ),
          _ActionChip(
            icon: Icons.bookmark_border,
            label: "Save",
            onTap: () {
              // save place
            },
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade200 : Colors.teal.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled ? Colors.grey : Colors.teal,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.grey : Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
