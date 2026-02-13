

class SearchIntentResolver {
  static final Map<String, List<String>> _aliases = {
    'vietnamese': ['viet', 'pho', 'banh mi'],
    'thai': ['thai'],
    'japanese': ['japanese', 'sushi', 'ramen'],
    'korean': ['korean', 'bbq'],
    'mexican': ['mexican', 'taco'],
    'italian': ['italian', 'pizza', 'pasta'],
    'american': ['burger', 'steak', 'fries'],
  };

  static String? resolveCategory(String query) {
    final q = query.toLowerCase();

    for (final entry in _aliases.entries) {
      for (final keyword in entry.value) {
        if (q.contains(keyword)) {
          return 'catering.restaurant.${entry.key}';
        }
      }
    }

    return null; // fallback
  }
}
