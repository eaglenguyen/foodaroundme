import 'package:flutter/material.dart';



class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Stack(
        children: [
          const Center(child: Text("Search page content")),

          // 🔍 Bottom search bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
