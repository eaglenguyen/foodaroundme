import 'package:flutter/material.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/action_row.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/header.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/photo_grid.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/social_links.dart';
import 'package:google_maps_webservice/places.dart';

import '../../model/place.dart';


class BottomSheetDetails extends StatelessWidget {
  final Place place;
  final PlaceDetails details;

  const BottomSheetDetails({
    super.key,
    required this.place,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.25,
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
                  ActionRow(place: place, details: details),
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



