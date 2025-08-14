import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore DB package

//  Final Seeder Function – Seeds full-body gym exercises across all major muscle groups
Future<void> seedAllGymExercises() async {
  final List<Map<String, dynamic>> exercises = [
    // -------- UPPER BODY --------
    {
      "name": "Barbell Bench Press",
      "equipment": "Barbell",
      "target": "Chest",
      "bodyPart": "Chest",
      "gif": "",
    },
    {
      "name": "Incline Dumbbell Press",
      "equipment": "Dumbbell",
      "target": "Upper Chest",
      "bodyPart": "Chest",
      "gif": "",
    },
    {
      "name": "Push Ups",
      "equipment": "None",
      "target": "Chest",
      "bodyPart": "Chest",
      "gif": "",
    },
    {
      "name": "Dumbbell Flyes",
      "equipment": "Dumbbell",
      "target": "Central Chest",
      "bodyPart": "Chest",
      "gif": "",
    },
    {
      "name": "Overhead Tricep Extension",
      "equipment": "Dumbbell",
      "target": "Triceps",
      "bodyPart": "Triceps",
      "gif": "",
    },
    {
      "name": "Tricep Dips",
      "equipment": "Bench",
      "target": "Triceps",
      "bodyPart": "Triceps",
      "gif": "",
    },
    {
      "name": "Barbell Curl",
      "equipment": "Barbell",
      "target": "Biceps",
      "bodyPart": "Biceps",
      "gif": "",
    },
    {
      "name": "Hammer Curl",
      "equipment": "Dumbbell",
      "target": "Biceps",
      "bodyPart": "Biceps",
      "gif": "",
    },
    {
      "name": "Shoulder Press",
      "equipment": "Dumbbell",
      "target": "Shoulders",
      "bodyPart": "Shoulders",
      "gif": "",
    },
    {
      "name": "Lateral Raises",
      "equipment": "Dumbbell",
      "target": "Shoulders",
      "bodyPart": "Shoulders",
      "gif": "",
    },
    {
      "name": "Shrugs",
      "equipment": "Dumbbell",
      "target": "Traps",
      "bodyPart": "Neck",
      "gif": "",
    },

    // -------- BACK & CORE --------
    {
      "name": "Pull Ups",
      "equipment": "Bodyweight",
      "target": "Lats",
      "bodyPart": "Back",
      "gif": "",
    },
    {
      "name": "Deadlifts",
      "equipment": "Barbell",
      "target": "Lower Back",
      "bodyPart": "Back",
      "gif": "",
    },
    {
      "name": "Plank",
      "equipment": "Mat",
      "target": "Core",
      "bodyPart": "Abs",
      "gif": "",
    },
    {
      "name": "Crunches",
      "equipment": "None",
      "target": "Abs",
      "bodyPart": "Abs",
      "gif": "",
    },
    {
      "name": "Russian Twists",
      "equipment": "None",
      "target": "Obliques",
      "bodyPart": "Abs",
      "gif": "",
    },

    // -------- LOWER BODY --------
    {
      "name": "Squats",
      "equipment": "Barbell",
      "target": "Quads",
      "bodyPart": "Quads",
      "gif": "",
    },
    {
      "name": "Lunges",
      "equipment": "Dumbbell",
      "target": "Quads",
      "bodyPart": "Quads",
      "gif": "",
    },
    {
      "name": "Leg Press",
      "equipment": "Machine",
      "target": "Quads",
      "bodyPart": "Quads",
      "gif": "",
    },
    {
      "name": "Hamstring Curl",
      "equipment": "Machine",
      "target": "Hamstrings",
      "bodyPart": "Hamstrings",
      "gif": "",
    },
    {
      "name": "Romanian Deadlift",
      "equipment": "Barbell",
      "target": "Hamstrings",
      "bodyPart": "Hamstrings",
      "gif": "",
    },
    {
      "name": "Hip Thrust",
      "equipment": "Barbell",
      "target": "Glutes",
      "bodyPart": "Glutes",
      "gif": "",
    },
    {
      "name": "Calf Raise",
      "equipment": "Bodyweight",
      "target": "Calves",
      "bodyPart": "Calves",
      "gif": "",
    },

    // -------- CARDIO --------
    {
      "name": "Jumping Jacks",
      "equipment": "None",
      "target": "Cardio",
      "bodyPart": "Cardio",
      "gif": "",
    },
    {
      "name": "High Knees",
      "equipment": "None",
      "target": "Cardio",
      "bodyPart": "Cardio",
      "gif": "",
    },
    {
      "name": "Mountain Climbers",
      "equipment": "None",
      "target": "Cardio",
      "bodyPart": "Cardio",
      "gif": "",
    },
  ];

  final batch = FirebaseFirestore.instance.batch();
  final collection = FirebaseFirestore.instance.collection('exercises');

  for (var ex in exercises) {
    final docRef = collection.doc();
    batch.set(docRef, {
      ...ex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  print(" Seeded all gym exercises successfully!");
}
