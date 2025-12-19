import 'package:flutter/material.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/action_row.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/header.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/photo_grid.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/social_links.dart';

import '../../model/place.dart';


class BottomSheetDetails extends StatelessWidget {
  final Place place;

  const BottomSheetDetails({
    super.key,
    required this.place
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F7FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(place: place),
                ActionRow(place: place),
                SocialLinks(place: place),
                PhotoGrid(place: place)
              ],
            ),
          ),
        );
      },
    );
  }
}
