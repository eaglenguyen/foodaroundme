import 'package:flutter/foundation.dart'; // needed for debugPrint in tests


// test/opening_hours_formatter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:foodaroundme/map/widgets/bottom_sheet_detail/header.dart';

void main() {

  // ─── normalizeTime ───────────────────────────────────────────────
  group('normalizeTime', () {
    test('trims whitespace', () {
      expect(normalizeTime('  09:00  '), '09:00');
    });

    test('converts 24:00 to 00:00', () {
      expect(normalizeTime('24:00'), '00:00');
    });

    test('converts bare hour to HH:00', () {
      expect(normalizeTime('11'), '11:00');
      expect(normalizeTime('9'), '9:00');
    });

    test('returns valid time unchanged', () {
      expect(normalizeTime('14:30'), '14:30');
    });
  });

  // ─── isOvernight ─────────────────────────────────────────────────
  group('isOvernight', () {
    test('returns false when end is 24:00', () {
      expect(isOvernight('22:00', '24:00'), false);
    });

    test('returns true when end is before start', () {
      expect(isOvernight('22:00', '02:00'), true);
    });

    test('returns false when end is after start', () {
      expect(isOvernight('09:00', '22:00'), false);
    });
  });

  // ─── expandDays ──────────────────────────────────────────────────
  group('expandDays', () {
    test('single day returns correct index', () {
      expect(expandDays('Mo'), [0]);
      expect(expandDays('Su'), [6]);
    });

    test('range Mo-Fr returns 0 to 4', () {
      expect(expandDays('Mo-Fr'), [0, 1, 2, 3, 4]);
    });

    test('comma separated days', () {
      expect(expandDays('Mo,We,Fr'), [0, 2, 4]);
    });

    test('mixed range and single days Mo-Th,Su', () {
      expect(expandDays('Mo-Th,Su'), [0, 1, 2, 3, 6]);
    });

    test('invalid day abbreviation is skipped', () {
      expect(expandDays('Xx'), []);
    });

    test('wrap around range Su-Tu', () {
      expect(expandDays('Su-Tu'), [6, 0, 1]);
    });
  });

  // ─── formatTime ──────────────────────────────────────────────────
  group('formatTime', () {
    test('midnight 00:00 formats to 12 AM', () {
      expect(formatTime('00:00'), '12 AM');
    });

    test('noon 12:00 formats to 12 PM', () {
      expect(formatTime('12:00'), '12 PM');
    });

    test('morning time formats correctly', () {
      expect(formatTime('09:00'), '9 AM');
    });

    test('afternoon time formats correctly', () {
      expect(formatTime('14:30'), '2:30 PM');
    });

    test('11pm formats correctly', () {
      expect(formatTime('23:00'), '11 PM');
    });

    test('drops :00 minutes', () {
      expect(formatTime('11:00'), '11 AM');
    });

    test('keeps non-zero minutes', () {
      expect(formatTime('11:30'), '11:30 AM');
    });
  });

  // ─── parseOpeningHours ───────────────────────────────────────────
  group('parseOpeningHours', () {

    test('simple single day', () {
      final result = parseOpeningHours('Mo 09:00-17:00');
      expect(result['Mo'], ['9 AM–5 PM']);
      expect(result['Tu'], isEmpty);
    });

    test('day range Mo-Fr', () {
      final result = parseOpeningHours('Mo-Fr 09:00-17:00');
      expect(result['Mo'], ['9 AM–5 PM']);
      expect(result['Tu'], ['9 AM–5 PM']);
      expect(result['We'], ['9 AM–5 PM']);
      expect(result['Th'], ['9 AM–5 PM']);
      expect(result['Fr'], ['9 AM–5 PM']);
      expect(result['Sa'], isEmpty);
      expect(result['Su'], isEmpty);
    });

    test('semicolon separated segments', () {
      final result = parseOpeningHours('Mo-Th 17:00-23:00; Fr-Sa 11:30-14:30,17:00-24:00; Su 11:30-14:30,17:00-23:00');
      expect(result['Mo'], ['5 PM–11 PM']);
      expect(result['Fr'], ['11:30 AM–2:30 PM', '5 PM–12 AM']);
      expect(result['Su'], ['11:30 AM–2:30 PM', '5 PM–11 PM']);
    });

    test('comma separated segments', () {
      final result = parseOpeningHours('Su 10:00-23:00, Mo-We 11:00-23:00, Th,Fr 11:00-24:00, Sa 10:00-24:00');
      expect(result['Su'], ['10 AM–11 PM']);
      expect(result['Mo'], ['11 AM–11 PM']); // ✅ 23:00 = 11 PM not 12 AM
      expect(result['Th'], ['11 AM–12 AM']); // ✅ 24:00 = 12 AM
      expect(result['Fr'], ['11 AM–12 AM']); // ✅ 24:00 = 12 AM
      expect(result['Sa'], ['10 AM–12 AM']); // ✅ 24:00 = 12 AM
    });


    test('mixed day group Mo-Th,Su', () {
      final result = parseOpeningHours('Mo-Th,Su 11:00-21:00; Fr-Sa 11:00-22:00');
      expect(result['Mo'], ['11 AM–9 PM']);
      expect(result['Tu'], ['11 AM–9 PM']);
      expect(result['We'], ['11 AM–9 PM']);
      expect(result['Th'], ['11 AM–9 PM']);
      expect(result['Su'], ['11 AM–9 PM']);
      expect(result['Fr'], ['11 AM–10 PM']);
      expect(result['Sa'], ['11 AM–10 PM']);
    });

    test('overnight hours add slot to next day', () {
      final result = parseOpeningHours('Fr 22:00-02:00');
      expect(result['Fr'], ['10 PM–2 AM']);
      expect(result['Sa'], ['12 AM–2 AM']); // ✅ overnight spills into Saturday
    });

    test('24:00 end time formats to 12 AM not overnight', () {
      final result = parseOpeningHours('Mo 09:00-24:00');
      expect(result['Mo'], ['9 AM–12 AM']);
      expect(result['Tu'], isEmpty); // ✅ 24:00 is NOT treated as overnight
    });

    test('multiple time slots in one day', () {
      final result = parseOpeningHours('Mo 11:30-14:30,17:00-22:00');
      expect(result['Mo'], ['11:30 AM–2:30 PM', '5 PM–10 PM']);
    });

    test('empty string returns all days empty', () {
      final result = parseOpeningHours('');
      for (final day in dayOrder) {
        expect(result[day], isEmpty);
      }
    });

    test('all days present in result even if empty', () {
      final result = parseOpeningHours('Mo 09:00-17:00');
      expect(result.keys.toList(), dayOrder);
    });
  });
  
}