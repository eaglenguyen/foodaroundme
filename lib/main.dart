import 'package:flutter/material.dart';
import 'package:foodaroundme/ui/main_screen.dart';
import 'package:foodaroundme/viewmodel/mapViewModel.dart';

import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        // created once the app starts for entire app
        ChangeNotifierProvider(create: (_) => MapViewModel()),
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
