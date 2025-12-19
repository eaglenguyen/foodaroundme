import 'package:flutter/material.dart';

import '../model/place.dart';

class BottomSheetMap extends StatelessWidget {
  final String title;
  // changed to function to take place object
  final void Function(Place) onSelect;
  final VoidCallback close;
  final List<Place> places;


  const BottomSheetMap({
    super.key,
    required this.title,
    required this.onSelect,
    required this.close,
    required this.places,
  });

  @override
  Widget build(BuildContext context) { return DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.25,
    minChildSize: 0.25,
    maxChildSize: 0.9,
    builder: (context, controller) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 16),

            /// drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Title
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// ⭐ The correct way to show the list
            /// p is the place object clicked
            ...places.map( (p) {
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(p.name),
                onTap:  () => onSelect(p),
              );
            }),


            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Close"),
              onTap: close,
            ),
          ],
        ),
      );
    },
  );
  }
}


