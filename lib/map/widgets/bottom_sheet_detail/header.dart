import 'package:flutter/material.dart';

import '../../model/place.dart';


class Header extends StatefulWidget {
  final Place place;
  final String rawHours;

  const Header({
    super.key,
    required this.place,
    required this.rawHours,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool expanded = false; // toggle for "show all hours"

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday; // 1=Mon, 7=Sun
    final todayKey = dayOrder[todayIndex - 1];
    final parsed = parseOpeningHours(widget.rawHours);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Place name
          Text(
            widget.place.name.length > 17
            ? '${widget.place.name.substring(0, 17)}..'
            : widget.place.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),


          // Address
          Text(
            cleanAddress(widget.place.address),
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 8),



          // Hours section
          if (!expanded)
          // Today only
    // Today only
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${dayNames[todayKey]}  ',
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            parsed[todayKey]?.isNotEmpty == true
                ? parsed[todayKey]!.join(', ')
                : 'Closed/Unavailable',
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    )
          else
// All days (expanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dayOrder.map((d) {
                final hours = parsed[d];
                final isToday = d == todayKey;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 48, // fixed width keeps all hours aligned
                        child: Text(
                          '${dayNames[d]}  ',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.blue : Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hours != null && hours.isNotEmpty
                              ? hours.join(', ')
                              : 'Closed/Unavailable',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.blue : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 4),

          // Toggle button
          TextButton.icon(
            onPressed: () => setState(() => expanded = !expanded),
            icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(expanded ? '' : 'Show all hours'),
          ),
        ],
      ),
    );
  }
}


String cleanAddress(String rawAddress) {
  if (rawAddress.isEmpty) return '';

  final parts = rawAddress.split(',');

  if (parts.length <= 1) return rawAddress; // fallback

  // Remove the first part (the place name) and trim each remaining part
  final addressOnly = parts.sublist(1).map((p) => p.trim()).join(', ');

  return addressOnly;
}




// Everything Below is formatter for hours open
const dayNames = {
  'Mo': 'Mon',
  'Tu': 'Tues',
  'We': 'Weds',
  'Th': 'Thurs',
  'Fr': 'Fri',
  'Sa': 'Sat',
  'Su': 'Sun',
};

const dayOrder = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

String normalizeTime(String t) {
  t = t.trim();
  if (t == '24:00') return '00:00';
  if (RegExp(r'^\d{1,2}$').hasMatch(t)) return '$t:00';
  return t;
}

bool isOvernight(String rawStart, String rawEnd) {
  if (rawEnd == '24:00') return false;
  return rawEnd.compareTo(rawStart) < 0;
}

List<int> expandDays(String dayPart) {
  final result = <int>[];

  for (final token in dayPart.split(',')) {
    final trimmed = token.trim();
    if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      final start = dayOrder.indexOf(parts[0].trim());
      final end = dayOrder.indexOf(parts[1].trim());

      if (start == -1 || end == -1) continue;

      if (start <= end) {
        for (int i = start; i <= end; i++) {
          result.add(i);
        }
      } else {
        for (int i = start; i < dayOrder.length; i++) {
          result.add(i);
        }
        for (int i = 0; i <= end; i++) {
          result.add(i);
        }
      }
    } else {
      final index = dayOrder.indexOf(trimmed);
      if (index != -1) result.add(index);
    }
  }

  return result;
}

String formatTime(String time) {
  final t = normalizeTime(time).trim();
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
  if (m == null) {
    debugPrint('Invalid time token: "$time"');
    return time; // graceful fallback instead of throwing
  }

  var hour = int.parse(m.group(1)!);
  final minute = m.group(2)!;

  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  return minute == '00' ? '$hour $suffix' : '$hour:$minute $suffix';
}

Map<String, List<String>> parseOpeningHours(String raw) {
  final schedule = {
    for (var d in dayOrder) d: <String>[],
  };

  final timeRangeRegex = RegExp(r'(\d{1,2}:\d{2})-(\d{1,2}:\d{2})');

  // ✅ Match any segment that starts with a day abbreviation followed by times
  // Handles both ";" and "," as segment separators
  final segmentRegex = RegExp(
    r'((?:Mo|Tu|We|Th|Fr|Sa|Su)(?:[-,](?:Mo|Tu|We|Th|Fr|Sa|Su))*)\s+'
    r'((?:\d{1,2}:\d{2}-\d{1,2}:\d{2}(?:,\s*)?)+)',
  );

  for (final match in segmentRegex.allMatches(raw)) {
    final daysPart = match.group(1)!.trim();
    final timesPart = match.group(2)!.trim();

    final dayIndexes = expandDays(daysPart);

    debugPrint('daysPart: "$daysPart" → indexes: $dayIndexes');
    debugPrint('timesPart: "$timesPart"');

    for (final timeMatch in timeRangeRegex.allMatches(timesPart)) {
      final rawStart = timeMatch.group(1)!.trim();
      final rawEnd = timeMatch.group(2)!.trim();

      final start = normalizeTime(rawStart);
      final end = normalizeTime(rawEnd);

      final overnight = isOvernight(rawStart, rawEnd);

      for (final i in dayIndexes) {
        final day = dayOrder[i];
        schedule[day]!.add('${formatTime(start)}–${formatTime(end)}');

        if (overnight) {
          final nextDay = dayOrder[(i + 1) % 7];
          schedule[nextDay]!.add('12 AM–${formatTime(end)}');
        }
      }
    }
  }

  return schedule;

}

