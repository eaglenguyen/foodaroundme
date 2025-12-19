import 'package:flutter/material.dart';
import '../../model/place.dart';




class SocialLinks extends StatelessWidget {
  final Place place;

  const SocialLinks({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
            _SocialLink(
              label: "see more on tiktok",
              icon: Icons.music_note,
              onTap: () {
                // open TikTok
              },
            ),
            const SizedBox(width: 16),

            _SocialLink(
              label: "see more on insta",
              icon: Icons.camera_alt,
              onTap: () {
                // open Instagram
              },
            ),
        ],
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16),
        ],
      ),
    );
  }
}
