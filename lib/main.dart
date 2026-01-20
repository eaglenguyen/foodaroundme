import 'package:flutter/material.dart';
import 'package:foodaroundme/repository/place_foursquare_repository.dart';
import 'package:foodaroundme/repository/place_repository.dart';
import 'package:foodaroundme/ui/main_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';

import 'package:provider/provider.dart';

import 'data/foursquare_api.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
        create: (_) => PlacesRepository(
            apiKey: MapViewModel.apiKey
        ),
        ),
        Provider<FoursquareApi>(
          create: (_) => FoursquareApi(
              apiKey: MapViewModel.apiKeyFourSquare
          ),
          ),

        Provider<PlacesFourSquareRepository>(
          create: (context) => PlacesFourSquareRepository(
            context.read<FoursquareApi>(),
          ),
        ),
        // created once the app starts for entire app
        ChangeNotifierProvider(create: (context) => MapViewModel(
          placesRepository: context.read<PlacesRepository>(),
          placesFourSquareRepository: context.read<PlacesFourSquareRepository>(),
        )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: MainScreen(),
    );
  }
}
