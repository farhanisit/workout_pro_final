// stats_utils_test.dart - Tests for computeWeekly function in stats_utils.dart
// - Validates correct grouping of DateTime objects into weekly counts
// - Ensures that empty lists return zeros
// - Uses Flutter's test package for unit testing

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_pro/services/stats_utils.dart';

void main() {
  test('computeWeekly groups Monday..Sunday correctly', () {
    // Mon(11), Mon(11), Wed(13), Sat(16) — August 2025 dates
    final sample = <DateTime>[
      DateTime(2025, 8, 11), // Mon
      DateTime(2025, 8, 11), // Mon again
      DateTime(2025, 8, 13), // Wed
      DateTime(2025, 8, 16), // Sat
    ];
    expect(computeWeekly(sample), [2, 0, 1, 0, 0, 1, 0]);
  });

  test('computeWeekly on empty list returns zeros', () {
    expect(computeWeekly(const []), [0, 0, 0, 0, 0, 0, 0]);
  });
}
