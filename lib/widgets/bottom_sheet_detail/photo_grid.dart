import 'package:flutter/material.dart';
import '../../model/place.dart';




class PhotoGrid extends StatelessWidget {
  final Place place;

  const PhotoGrid({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder count for now
    const itemCount = 6;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, index) {
          return _MediaPlaceholder();
        },
      ),
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_fill,
          size: 40,
          color: Colors.white70,
        ),
      ),
    );
  }
}
