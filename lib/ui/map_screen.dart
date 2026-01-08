import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_sheet_detail/bottom_sheet_details.dart';
import '../widgets/bottom_sheet_map.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
          onMapCreated: viewModel.onMapCreated,
          onCameraMove: viewModel.onCameraMove,
          onCameraIdle: viewModel.onCameraIdle,
          initialCameraPosition: CameraPosition(
            target: viewModel.center,
            zoom: 11.0,
      ),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: {
        Marker(
            markerId: const MarkerId('currentLocation'),
            position: viewModel.center,
            infoWindow: const InfoWindow(title: "You're here"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            )
        ),
        ...viewModel.markers,
      },
    ),

        if(viewModel.isLoading)
          Positioned.fill(
              child: const Center(
                child: CircularProgressIndicator(),
          ),
          ),
          /// PERSISTENT BOTTOM SHEET
          if (viewModel.showBottomSheet)
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomSheetMap(
                title: viewModel.sheetTitle,
                places: viewModel.filteredPlaces,
                close: viewModel.closeSheet,
                onSelect: (place) async {
                  viewModel.selectPlace(place);

                  final details =
                  await viewModel.getPlaceDetails(place.placeId);

                  if (!context.mounted || details == null) return;

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BottomSheetDetails(
                      place: place,
                      details: details,
                    ),
                  );
                },
              ),
            ),
      ],
    )
    );


  }
}