import 'package:flutter/material.dart';
import 'package:foodaroundme/repository/PlacesRepository.dart';
import 'package:foodaroundme/repositoryImp/google_repo_impl.dart';
import 'package:foodaroundme/ui/main_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';

import 'package:provider/provider.dart';



void main() {
  const googleApiKey = String.fromEnvironment("GOOGLE_MAPS_API_KEY");

  runApp(
    MultiProvider(
      providers: [
        Provider<PlacesRepository>(
        create: (_) => GoogleRepoImpl(googleApiKey),
        ),
        // created once the app starts for entire app
        ChangeNotifierProvider(create: (context) => MapViewModel(
          placesRepository: context.read<PlacesRepository>(),
        )
        ),
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
