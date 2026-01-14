import 'package:flutter/material.dart';
import 'package:foodaroundme/repository/place_repository.dart';
import 'package:foodaroundme/ui/main_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';

import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
        create: (_) => PlacesRepository(
            apiKey: MapViewModel.apiKey
        ),
        ),
        // created once the app starts for entire app
        ChangeNotifierProvider(create: (context) => MapViewModel(
            placesRepository: context.read<PlacesRepository>(),
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
