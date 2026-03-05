import 'package:flutter/material.dart';




class PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;

  const PhotoGrid({
    super.key,
    required this.photoUrls,
  });

  @override
  Widget build(BuildContext context) {
    if(photoUrls.isEmpty){
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            "No Photos Available",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Padding(padding: EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: photoUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, index) {
          return _PhotoTile(url: photoUrls[index]);
        }
    ));
  }
}

class _PhotoTile extends StatelessWidget {
  final String url;

  const _PhotoTile({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade800,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            color: Colors.grey.shade700,
            child: const Icon(Icons.image_not_supported),
          );
        },
      ),
    );
  }
}
