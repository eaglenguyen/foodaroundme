import 'package:flutter/material.dart';
import 'package:foodaroundme/repository/PlacesRepository.dart';
import 'package:foodaroundme/repositoryImp/foursquare_repo_impl.dart';
import 'package:foodaroundme/repositoryImp/geoapify_repo_impl.dart';
import 'package:foodaroundme/repositoryImp/google_repo_impl.dart';
import 'package:foodaroundme/ui/main_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';
import 'package:path/path.dart';

import 'package:provider/provider.dart';

import 'local/app_database.dart';



void main() {
  const googleApiKey = String.fromEnvironment("GOOGLE_MAPS_API_KEY");
  const apiKeyFourSquare = String.fromEnvironment("FOURSQUARE_API_KEY");
  const geoapifyKey = String.fromEnvironment("GEOAPIFY_API_KEY");
  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<PlacesRepository>(
        create: (context) => GeoapifyRepoImpl(geoapifyKey, context.read<AppDatabase>()), // switch apis here
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
