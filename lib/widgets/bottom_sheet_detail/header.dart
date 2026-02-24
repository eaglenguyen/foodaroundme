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
            widget.place.name,
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
            Text(
              '${dayNames[todayKey]}  ${parsed[todayKey]?.join(', ') ?? 'Closed'}',
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            )
          else
          // All days
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dayOrder.map((d) {
                final hours = parsed[d];
                return Text(
                  '${dayNames[d]}  ${hours!.isNotEmpty ? hours.join(', ') : 'Closed'}',
                  style: TextStyle(
                    fontWeight: d == todayKey ? FontWeight.bold : FontWeight.normal,
                    color: d == todayKey ? Colors.blue : Colors.black54,
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

String normalizeTime(String t) => t == '24:00' ? '00:00' : t;

bool isOvernight(String rawStart, String rawEnd) {
  if (rawEnd == '24:00') return false;
  return rawEnd.compareTo(rawStart) < 0;
}

List<int> expandDays(String dayPart) {
  final result = <int>[];

  for (final token in dayPart.split(',')) {
    if (token.contains('-')) {
      final parts = token.split('-');
      final start = dayOrder.indexOf(parts[0]);
      final end = dayOrder.indexOf(parts[1]);

      if (start == -1 || end == -1) continue;

      // Handle wrap-around (Su-Mo etc)
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
      final index = dayOrder.indexOf(token);
      if (index != -1) result.add(index);
    }
  }

  return result;
}

String formatTime(String time) {
  final parts = normalizeTime(time).split(':');
  int hour = int.parse(parts[0]);
  final minute = parts[1];

  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;

  return minute == '00'
      ? '$hour $suffix'
      : '$hour:$minute $suffix';
}

Map<String, List<String>> parseOpeningHours(String raw) {
  final schedule = {
    for (var d in dayOrder) d: <String>[],
  };

  final segments = raw.split(';');

  for (final segment in segments) {
    final match = RegExp(r'^([\w,-]+)\s+(.+)$').firstMatch(segment.trim());
    if (match == null) continue;

    final daysPart = match.group(1)!;
    final timesPart = match.group(2)!;

    final dayIndexes = expandDays(daysPart);

    for (final range in timesPart.split(',')) {
      final t = range.split('-');
      if (t.length != 2) continue;

      final rawStart = t[0];
      final rawEnd = t[1];

      final start = normalizeTime(rawStart);
      final end = normalizeTime(rawEnd);

      final overnight = isOvernight(rawStart, rawEnd);



      for (final i in dayIndexes) {
        final day = dayOrder[i];

        schedule[day]!
            .add('${formatTime(start)}–${formatTime(end)}');


        // spill into next day if overnight
        if (overnight) {
          final nextDay = dayOrder[(i + 1) % 7];
          schedule[nextDay]!
              .add('12 AM–${formatTime(end)}');
        }
      }
    }
  }

  return schedule;
}

List<String> formatForUI(String raw) {
  final parsed = parseOpeningHours(raw);

  return dayOrder
      .where((d) => parsed[d]!.isNotEmpty)
      .map((d) => '${dayNames[d]}  ${parsed[d]!.join(', ')}')
      .toList();
}



