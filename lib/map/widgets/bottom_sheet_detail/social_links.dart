import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            _SocialLink(
              label: "see more on tiktok",
              icon: Icons.music_note,
              onTap: () async {
                final confirmed = await showHashtagDisclaimer(context);
                if (confirmed == true) {
                  openTikTok(place.name);
                }
                },
            ),
            const SizedBox(width: 16),

            _SocialLink(
              label: "see more on instagram",
              icon: Icons.camera_alt,
              onTap: () async {
                final confirmed = await showHashtagDisclaimer(context);
                if (confirmed == true) {
                  openInstagramTag(place.name);
                }
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
          Icon(icon, size: 20),
        ],
      ),
    );
  }
}


// Restaurant detailScreen
Future<void> openTikTok(String restaurantName) async {
  final query = Uri.encodeComponent(restaurantName);
  final url = 'https://www.tiktok.com/tag/$query';
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not open TikTok';
  }
}

Future<void> openInstagramTag(String tag) async {
  final encodedTag = Uri.encodeComponent(tag);
  final url = 'https://www.instagram.com/explore/tags/$encodedTag/';
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not open Instagram tag';
  }
}

Future<bool?> showHashtagDisclaimer(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Disclaimer"),
      content: const Text(
        "Since the hashtags are based off the restaurant's name, "
            "results may vary for TikToks and Instagram Reels.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}