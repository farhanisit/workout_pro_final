// exercise_service_test.dart - Unit tests for ExerciseService
// - Tests CRUD operations and weekly stats computation
// - Uses FakeFirebaseFirestore for isolated testing
// - Ensures correct storage path detection and data integrity

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:workout_pro/services/exercise_service.dart';
import 'package:workout_pro/model/exercise.dart';

void main() {
  late FakeFirebaseFirestore fake;
  late ExerciseService svc;

  // Will point to the actual collection your service uses (subcollection or top-level)
  late CollectionReference<Map<String, dynamic>> root;

  setUp(() async {
    fake = FakeFirebaseFirestore();

    // ensure parent user doc exists (needed if service uses subcollection)
    await fake.collection('users').doc('u1').set({'_': true});

    // inject uid; avoids FirebaseAuth path
    svc = ExerciseService(firestore: fake, userId: 'u1');

    // ---- Detect storage path used by the service ----
    const probeName = '__probe__';
    await svc.createExercise(Exercise(
      id: null,
      name: probeName,
      gif: 'p.gif',
      equipment: 'None',
      target: '1',
      bodyPart: 'core',
      duration: null,
      createdAt: DateTime.now(),
    ));

    final sub = fake.collection('users').doc('u1').collection('exercises');
    final subHit = await sub.where('name', isEqualTo: probeName).limit(1).get();
    if (subHit.docs.isNotEmpty) {
      root = sub;
      await sub.doc(subHit.docs.first.id).delete();
    } else {
      final top = fake.collection('exercises');
      final topHit =
          await top.where('name', isEqualTo: probeName).limit(1).get();
      if (topHit.docs.isEmpty) {
        throw StateError('Could not detect ExerciseService storage path.');
      }
      root = top;
      await top.doc(topHit.docs.first.id).delete();
    }
  });

  // matches your Exercise model
  Exercise makeExercise({
    String? id,
    String name = 'Pushups',
    String gif = 'pushups.gif',
    String equipment = 'None',
    String target = '10',
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
    final snap = await root.get(); // no createdAt filter
    expect(snap.docs.length, greaterThan(0));
    final data = snap.docs.first.data();
    expect(data['bodyPart'], 'chest');
    expect(data['target'], '10'); // String in your model
  });

  test('weekly stats compute Mon→Sun counts (in-range seeds)', () async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));

    Future<void> seed(int day, String name, String bp) async {
      await root.add({
        'name': name,
        'gif': '$name.gif',
        'equipment': 'None',
        'target': '5',
        'bodyPart': bp,
        'duration': null,
        'createdAt': Timestamp.fromDate(start.add(Duration(days: day))),
      });
    }

    await seed(0, 'A', 'legs');
    await seed(3, 'B', 'back');
    await seed(6, 'C', 'core');

    final weekly = await svc.getWeeklyWorkoutData();
    expect(weekly.length, 7);
    expect(weekly.fold<int>(0, (a, b) => a + b), greaterThan(0));
  });

  test('update + delete', () async {
    await svc.createExercise(
        makeExercise(name: 'Squats', bodyPart: 'legs', target: '12'));

    final all = await root.get();
    expect(all.docs, isNotEmpty);
    final id = all.docs.first.id;

    await svc.updateExercise(
      id,
      makeExercise(id: id, name: 'Squats', bodyPart: 'legs', target: '15'),
    );

    var doc = await root.doc(id).get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['target'], '15');

    await svc.deleteExercise(id);
    doc = await root.doc(id).get();
    expect(doc.exists, isFalse);
  });
}
