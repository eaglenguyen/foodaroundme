import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../model/place.dart';
import '../widgets/bottom_sheet_detail/bottom_sheet_details.dart';
import '../widgets/bottom_sheet_map.dart';


class MapScreen extends StatelessWidget {


  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final id = vm.consumeOpenDetailsRequest();
          if (id == null) return;

          final details = await vm.getPlaceDetails(id);
          if (!context.mounted || details == null) return;

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => BottomSheetDetails(place: details),
          );
        });


    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            style: viewModel.darkMapStyle,
            onMapCreated: viewModel.onMapCreated,
            onCameraMove: viewModel.onCameraMove,
            onCameraIdle: () {
              viewModel.onCameraIdle();
            },
            initialCameraPosition: CameraPosition(
            target: viewModel.center,
            zoom: 11.0,
      ),
            circles: viewModel.circles,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: viewModel.center,
                infoWindow: const InfoWindow(title: "You're here"),
                icon: viewModel.currentIcon,
              ),
              ...viewModel.markers,
      },
    ),

          Positioned(
            bottom: 40, // 👈 move anywhere you want
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: viewModel.moveToUserLocation,
              child: const Icon(
                Icons.my_location,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 16,
            child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            elevation: 4,
            onPressed: viewModel.resetCamera,
            child: const Icon(
              Icons.refresh_sharp,
              color: Colors.black,
            ),
          ),
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
                count: viewModel.visibleCount,
                addCount: viewModel.addCount,
                isLoading: viewModel.isLoading,
                close: () {
                  viewModel.closeSheet();
                  viewModel.showExpandableFabAgain();
                },
                 onSelect: (place)  {
                  _openPlaceDetails(context, place);
                },
              ),
            ),


      ],
    )
    );


  }
  );
}
}

Future<void> _openPlaceDetails(BuildContext context, Place place) async {
  final vm = context.read<MapViewModel>();

  vm.selectPlace(place);

  final details = await vm.getPlaceDetails(place.id);
  if (!context.mounted || details == null) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BottomSheetDetails(place: details),
  );
}
