// test/services/exercise_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/model/exercise.dart';

void main() {
  late FakeFirebaseFirestore fake;
  late ExerciseService svc;

  setUp(() {
    fake = FakeFirebaseFirestore();
    svc = ExerciseService.test(firestore: fake, userId: 'u1'); // DI, as in your app
  });

  // Helper that matches your Exercise model (named params; target is String; DateTime? createdAt)
  Exercise makeExercise({
    String? id,
    String name = 'Pushups',
    String gif = 'https://example.com/pushups.gif',
    String equipment = 'None',
    String target = '10', // <-- String (matches your model)
    String bodyPart = 'chest',
    int? duration,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id,
      name: name,
      gif: gif,
      equipment: equipment,
      target: target,
      bodyPart: bodyPart,
      duration: duration,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  test('create + read back', () async {
    await svc.createExercise(makeExercise());

    final snap = await fake
        .collection('exercises')
        .where('name', isEqualTo: 'Pushups')
        .limit(1)
        .get();

    expect(snap.docs, isNotEmpty);
    final data = snap.docs.first.data();
    expect(data['bodyPart'], 'chest');
    expect(data['target'], '10'); // target stored as String
  });

  test('weekly stats compute Mon→Sun counts', () async {
    final now = DateTime.now();

    // Seed three docs on different weekdays (fields match your model)
    await fake.collection('exercises').add({
      'name': 'A',
      'gif': 'a.gif',
      'equipment': 'None',
      'target': '5', // String
      'bodyPart': 'legs',
      'createdAt': Timestamp.fromDate(now),
    });
    await fake.collection('exercises').add({
      'name': 'B',
      'gif': 'b.gif',
      'equipment': 'Band',
      'target': '8',
      'bodyPart': 'back',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
    });
    await fake.collection('exercises').add({
      'name': 'C',
      'gif': 'c.gif',
      'equipment': 'Mat',
      'target': '6',
      'bodyPart': 'core',
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
    });

    final weekly = await svc.getWeeklyWorkoutData(); // Future<List<int>>
    expect(weekly.length, 7);
    expect(weekly.reduce((a, b) => a + b) > 0, isTrue);
  });

  test('update + delete', () async {
    await svc.createExercise(
        makeExercise(name: 'Squats', bodyPart: 'legs', target: '12'));

    // Find the created doc’s ID
    final created = await fake
        .collection('exercises')
        .where('name', isEqualTo: 'Squats')
        .limit(1)
        .get();
    final id = created.docs.first.id;

    // Update using your API (expects an Exercise model)
    await svc.updateExercise(
      id,
      makeExercise(id: id, name: 'Squats', bodyPart: 'legs', target: '15'),
    );

    var doc = await fake.collection('exercises').doc(id).get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['target'], '15');

    await svc.deleteExercise(id);
    doc = await fake.collection('exercises').doc(id).get();
    expect(doc.exists, isFalse);
  });
}
