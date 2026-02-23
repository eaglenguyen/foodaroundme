import 'package:flutter/material.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/action_row.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/header.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/photo_grid.dart';
import 'package:foodaroundme/widgets/bottom_sheet_detail/social_links.dart';
import 'package:foodaroundme/widgets/drag_handles/drag_handle_line.dart';
import '../../model/place.dart';

// When in final production, look at possibility that details.photos can be null. Line 71
class BottomSheetDetails extends StatelessWidget {
  final Place place;

  const BottomSheetDetails({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
            children: [

              SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(place: place, rawHours: place.openingHours ?? "",),
                  ActionRow(place: place),
                  SocialLinks(place: place),
                  PhotoGrid(photoUrls: place.photoUrls)
                ],
              ),
            ),
              // Drag Handle
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: DragHandleLine(color: Colors.black26)
                ),
              ),

            ]
            )

        );
        },
      );
  }
}

// Places Photo Billing
