import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_pro/services/stats_utils.dart';

void main() {
  test('splitByBodyPart counts last 30d and normalizes', () async {
    final ff = FakeFirebaseFirestore();
    final col = ff.collection('exercises');
    final now = DateTime.now();

    // In-window docs
    await col.add({
      'bodyPart': 'Legs',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3)))
    });
    await col.add({
      'bodyPart': 'legs',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 29)))
    });
    await col.add({
      'bodyPart': 'BACK',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1)))
    });

    // Out-of-window (should be ignored)
    await col.add({
      'bodyPart': 'chest',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 45)))
    });
    await col.add({
      'bodyPart': 'legs ',
      'createdAt': Timestamp.fromDate(now.add(const Duration(days: 1)))
    });

    final snap = await col.get();
    final result = splitByBodyPart(snap.docs);

    expect(result, {'legs': 2, 'back': 1});
  });
}
