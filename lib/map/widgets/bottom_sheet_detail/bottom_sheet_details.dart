import 'package:flutter/material.dart';
import 'package:foodaroundme/map/widgets/bottom_sheet_detail/like_button/like_dislike.dart';
import 'package:foodaroundme/map/widgets/bottom_sheet_detail/photo_grid.dart';
import 'package:foodaroundme/map/widgets/bottom_sheet_detail/social_links.dart';
import 'package:provider/provider.dart';
import '../../model/place.dart';
import '../../viewmodel/map_viewmodel.dart';
import 'drag_handle_line.dart';
import 'action_row.dart';
import 'header.dart';

// When in final production, look at possibility that details.photos can be null. Line 71
class BottomSheetDetails extends StatelessWidget {
  final Place place;

  const BottomSheetDetails({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final mapVm = context.watch<MapViewModel>();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      minChildSize: 0.1,
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
              // Close Button + Like/Dislike (Top Right)
              Positioned(
                top: 12,
                right: 15,
                child: Row(
                  children: [
                    Column(
                      children: [
                        LikeButtons(providerPlaceId: place.id)
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Close button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        mapVm.closeSheet();
                        mapVm.showExpandableFabAgain();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),


            ]
            )

        );
        },
      );
  }
}
