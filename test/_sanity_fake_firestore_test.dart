import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('fake can write/read users/u1/exercises', () async {
    final fake = FakeFirebaseFirestore();
    await fake.collection('users').doc('u1').set({'_': true});
    await fake.collection('users').doc('u1').collection('exercises').add({
      'name': 'probe',
      'createdAt': Timestamp.now(),
    });
    final got =
        await fake.collection('users').doc('u1').collection('exercises').get();
    expect(got.docs.length, greaterThan(0));
  });
}
