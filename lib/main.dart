import 'package:flutter/material.dart';
import 'package:foodaroundme/app_root.dart';
import 'package:foodaroundme/map/repositoryImp/geoapify_repo_impl.dart';
import 'package:foodaroundme/service/subscription/revenuecat_service.dart';
import 'package:foodaroundme/service/subscription/subscription_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authentication/viewmodel/authViewModel.dart';
import 'map/local/app_database.dart';
import 'map/repository/PlacesRepository.dart';
import 'map/viewmodel/map_viewmodel.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  await Supabase.initialize(
    url: 'https://llxhwworkafjuuokswbq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxseGh3d29ya2FmanV1b2tzd2JxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyNTQ4ODIsImV4cCI6MjA4NjgzMDg4Mn0.VPUQB0abc3qG6SA6PJwP5hXjPrTrKuvB4ReZWKvtuRI',
  );

  final rcService = RevenueCatService();
  await rcService.init();
  final user = supabase.auth.currentUser;

  // ✅ restore identity BEFORE UI starts
  if (user != null) {
    await Purchases.logIn(user.id);
  }


  // when adding new keys make sure to pass into android build. Run , edit , add to args
  const googleApiKey = String.fromEnvironment("GOOGLE_MAPS_API_KEY");
  const apiKeyFourSquare = String.fromEnvironment("FOURSQUARE_API_KEY");
  const geoapifyKey = String.fromEnvironment("GEOAPIFY_API_KEY");
  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<RevenueCatService>.value(value: rcService), // ✅ add this

        Provider<AppDatabase>.value(value: database),
        Provider<PlacesRepository>(
        create: (context) => GeoapifyRepoImpl(geoapifyKey, context.read<AppDatabase>()), // switch apis here
        ),
        // created once the app starts for entire app
        ChangeNotifierProvider(create: (context) => MapViewModel(
          placesRepository: context.read<PlacesRepository>())),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SubscriptionViewModel()..init()),

      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: true,
      home: const AppRoot(),
    );
  }
}
