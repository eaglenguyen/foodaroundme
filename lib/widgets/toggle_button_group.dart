import 'package:flutter/material.dart';

class ToggleIconGroup extends StatefulWidget {
  final List<IconData> icons;
  final ValueChanged<int> onSelected;

  const ToggleIconGroup({
    super.key,
    required this.icons,
    required this.onSelected,
  });

  @override
  State<ToggleIconGroup> createState() => _ToggleIconGroupState();
}

class _ToggleIconGroupState extends State<ToggleIconGroup> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black26,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.icons.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onSelected(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icons[index],
                  size: 20,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
