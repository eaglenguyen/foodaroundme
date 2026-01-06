import 'package:flutter/material.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MapViewModel>(context);



    return GoogleMap(
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
    );

  }
}