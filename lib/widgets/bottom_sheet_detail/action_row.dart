import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
            onTap: () => showDirectionsPicker(context, place),
          ),
          _ActionChip(
            icon: Icons.language,
            label: "Website",
            onTap: place.website == null ? null : () {
              launchUrl(Uri.parse(place.website!));
            },
          ),
          _ActionChip(
            icon: Icons.call,
            label: "Call",
            onTap: place.phone == null
                ? null
                : () => callPlace(place.phone),
          ),
          _ActionChip(
            icon: Icons.share,
            label: "Share",
            onTap: () {
              sharePlace(context, place);
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



Future<void> callPlace(String? phone) async {
  if (phone == null || phone.isEmpty) return;

  // Remove spaces, dashes, parentheses
  final sanitizedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri(scheme: 'tel', path: sanitizedPhone);

  if(!await canLaunchUrl(uri)) {
    debugPrint('Could not launch phone dialer');
    return;
  }

  await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
  );
}

// IOS/IPad requires a source rectangle for popovers/anchor, hence the context parameter
void sharePlace(
    BuildContext context,
    Place place,
    ) {
  final box = context.findRenderObject() as RenderBox?;

  final text = '''
${place.name}
${place.address}

${place.website ?? ''}
'''.trim();

  Share.share(
    text,
    sharePositionOrigin:
    box!.localToGlobal(Offset.zero) & box.size,
  );
}

void showDirectionsPicker(
    BuildContext context,
    Place place,
    ) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.map),
          title: const Text("Apple Maps"),
          onTap: () {
            Navigator.pop(context);
            launchUrl(
              Uri.parse(
                'http://maps.apple.com/?daddr='
                    '${place.location.latitude},'
                    '${place.location.longitude}',
              ),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.map_outlined),
          title: const Text("Google Maps"),
          onTap: () {
            Navigator.pop(context);
            launchUrl(
              Uri.parse(
                'https://www.google.com/maps/dir/?api=1'
                    '&destination='
                    '${place.location.latitude},'
                    '${place.location.longitude}',
              ),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
    ),
  );
}





