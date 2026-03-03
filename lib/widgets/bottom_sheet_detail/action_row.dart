
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../authentication/viewmodel/authViewModel.dart';
import '../../main.dart';
import '../../model/place.dart';



class ActionRow extends StatelessWidget {
  final Place place;

  const ActionRow({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          CustomActionChip(
            icon: Icons.directions,
            label: "Directions",
            onTap: () => showDirectionsPicker(context, place),
          ),
          CustomActionChip(
            icon: Icons.language,
            label: "Website",
            onTap: () {
              final raw = place.website;
              if (raw == null || raw.isEmpty) return;

              final url = raw.startsWith('http')
                ? raw
                : 'https://$raw';

              final uri = Uri.tryParse(url);
              if (uri == null) return;

              launchUrl(
                uri,
                mode: LaunchMode.externalApplication);
          },
          ),
          CustomActionChip(
            icon: Icons.call,
            label: "Call",
            onTap: place.phone == null
                ? null
                : () => callPlace(place.phone),
          ),
          CustomActionChip(
            icon: Icons.share,
            label: "Share",
            onTap: () {
              sharePlace(context, place);
            },
          ),
          CustomActionChip(
            icon: Icons.bookmark_border,
            label: "Save",
            onTap: ()  {
              authVm.savePlace(place);
            },
          ),
        ],
      ),
    );
  }
}

class CustomActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const CustomActionChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return ActionChip(
      onPressed: onTap,
      elevation: 0,
      pressElevation: 2,
      backgroundColor: isDisabled
          ? const Color(0xFF2A2233)
          : const Color(0xFF241C2E),
      disabledColor: const Color(0xFF2A2233),
      side: BorderSide(
        color: isDisabled
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.08),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      avatar: Icon(
        icon,
        size: 18,
        color: isDisabled ? Colors.white38 : const Color(0xFFF5C518),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDisabled ? Colors.white38 : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}


Future<void> callPlace(String? phone) async {
  if (phone == null || phone.isEmpty) return;

  // Keep digits and plus only
  var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

  // Ensure only one leading +
  if (cleaned.startsWith('+')) {
    cleaned = '+${cleaned.substring(1).replaceAll('+', '')}';
  }

  final uri = Uri(scheme: 'tel', path: cleaned);

  if (!await canLaunchUrl(uri)) {
    debugPrint('Could not launch phone dialer');
    return;
  }

  await launchUrl(uri, mode: LaunchMode.externalApplication);
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





