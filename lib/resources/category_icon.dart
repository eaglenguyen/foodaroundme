// ✅ Map category to icon
import 'package:flutter/material.dart';

IconData categoryIcon(List<String> categories) {
  final cat = categories.join().toLowerCase();

  // ── keyword → icon buckets ──────────────────────────
  Map<IconData, List<String>> buckets = {
    Icons.coffee_rounded:         ['cafe', 'coffee'],
    Icons.local_bar_rounded:      ['bar', 'pub'],
    Icons.local_pizza_rounded:    ['pizza', 'italian'],
    Icons.ramen_dining_rounded:   ['ramen', 'noodle', 'vietnamese','dumpling', 'beef_bowl',
      'curry', 'chinese', 'taiwanese',
      'oriental', 'korean', 'thai', 'indian', 'nepali',
      'pakistani', 'indonesian', 'malay', 'malaysian',
      'filipino', 'asian'],
    Icons.lunch_dining_rounded:   ['burger', 'taco', 'tex-mex', 'american', 'western', 'mexican','chicken',
      'wings', 'fish_and_chips'],
    Icons.breakfast_dining_rounded: ['sandwich', 'pita'],
    Icons.set_meal_rounded:       ['sushi', 'japanese', 'fish', 'seafood'],
    Icons.soup_kitchen_rounded:   ['soup'],
    Icons.kebab_dining_rounded:   ['kebab', 'arab', 'lebanese', 'syrian', 'persian',
      'turkish', 'georgian', 'uzbek', 'afghan',
      'greek', 'mediterranean'],
    Icons.outdoor_grill_rounded:  ['barbecue', 'steak', 'beef', 'chili'],
    Icons.tapas_rounded:          ['tapas', 'spanish', 'portuguese'],
    Icons.bakery_dining_rounded:  ['french'],
    Icons.sports_bar_rounded:     ['german', 'bavarian', 'austrian', 'irish'],
    Icons.whatshot_rounded:       ['chili'],
    Icons.icecream_rounded:       ['dessert', 'ice'],
    Icons.fastfood_rounded:       ['fast'],
    Icons.public_rounded:         ['international', 'regional'],
    Icons.restaurant_rounded:     ['moroccan', 'ethiopian', 'african', 'balkan', 'croatian',
      'czech', 'hungarian', 'ukrainian', 'russian', 'swedish',
      'danish', 'belgian', 'european', 'latin', 'peruvian',
      'bolivian', 'argentinian', 'brazilian', 'caribbean',
      'cuban', 'jamaican'],
  };

  for (final entry in buckets.entries) {
    if (entry.value.any((keyword) => cat.contains(keyword))) {
      return entry.key;
    }
  }

  return Icons.restaurant_rounded;
}

String formatCategories(dynamic rawCategories) {
  if (rawCategories == null) return 'Restaurant';

  final categories = List<String>.from(rawCategories);

  const allowedPrefixes = [
    'restaurant.',
    'catering.',
  ];

  final cuisines = categories
  // keep only allowed category types
      .where((c) => allowedPrefixes.any((p) => c.startsWith(p)))
  // keep only allowed category types
      .map((c) => c.split('.').last)
      .map((c) => c.replaceAll('_', ' '))
      .map((c) =>
  c.isEmpty ? c : c[0].toUpperCase() + c.substring(1))
      .toSet()
      .toList();

  // Remove 'Restaurant' if there are other cuisines
  if (cuisines.length > 1) {
    cuisines.remove('Restaurant');
  }

  return cuisines.isEmpty ? 'Restaurant' : cuisines.join(' • ');
}