// lib/services/stats_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns counts for Monday..Sunday (index 0..6) from a list of DateTimes.
/// ISO weekday: Monday=1..Sunday=7 → we map to 0..6.
List<int> computeWeekly(List<DateTime> stamps) {
  final counts = List<int>.filled(7, 0);
  for (final dt in stamps) {
    final idx = (dt.weekday - 1) % 7;
    counts[idx] += 1;
  }
  return counts;
}

/// Builds a 30‑day body-part histogram from Firestore docs.
/// Expected fields:
/// - bodyPart: String (normalized later to lowercase.trim())
/// - createdAt: Timestamp (Firestore)
Map<String, int> splitByBodyPart(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final now = DateTime.now();
  final lower = now.subtract(const Duration(days: 30));
  final out = <String, int>{};

  for (final d in docs) {
    final data = d.data();
    final ts = (data['createdAt'] as Timestamp?)?.toDate();
    if (ts == null || ts.isBefore(lower) || ts.isAfter(now)) continue;

    final raw = data['bodyPart'];
    if (raw is! String) continue;
    final bp = raw.toLowerCase().trim();
    if (bp.isEmpty) continue;

    out[bp] = (out[bp] ?? 0) + 1;
  }
  return out;
}
