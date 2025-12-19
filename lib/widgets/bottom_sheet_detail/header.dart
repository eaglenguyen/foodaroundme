import 'package:flutter/material.dart';

import '../../model/place.dart';


class Header extends StatelessWidget {
  final Place place;

  const Header({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            place.address,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
