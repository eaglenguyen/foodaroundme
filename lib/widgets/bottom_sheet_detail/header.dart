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
            cleanAddress(place.address) ,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            cleanAddress(place.) ,
            style: const TextStyle(color: Colors.black54),
          ),
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


String cleanAddress(String rawAddress) {
  if (rawAddress.isEmpty) return '';

  final parts = rawAddress.split(',');

  if (parts.length <= 1) return rawAddress; // fallback

  // Remove the first part (the place name) and trim each remaining part
  final addressOnly = parts.sublist(1).map((p) => p.trim()).join(', ');

  return addressOnly;
}