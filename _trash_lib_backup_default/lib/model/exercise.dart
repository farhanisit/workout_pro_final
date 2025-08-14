import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp

/// Represents a workout exercise with optional Firestore ID and timestamp.
class Exercise {
  final String? id;
  final String name;
  final String gif;
  final String equipment;
  final String target;
  final String bodyPart;
  final int? duration;

  final DateTime? createdAt; // ✅ Add this field

  // Creates an [Exercise] instance.
  const Exercise({
    this.id,
    required this.name,
    required this.gif,
    required this.equipment,
    required this.target,
    required this.bodyPart,
    this.duration,
    this.createdAt, // ✅ Include it here
  });

  // Converts an Exercise object into a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'gif': gif.trim(),
      'equipment': equipment.trim(),
      'target': target.trim(),
      'bodyPart': bodyPart.trim(),
      'duration': duration,
      'createdAt':
          createdAt, // optional: could omit if using serverTimestamp only
    };
  }

  // Constructs an Exercise instance from Firestore document data.
  factory Exercise.fromMap(Map<String, dynamic> data, String documentId) {
    return Exercise(
      id: documentId,
      name: (data['name'] as String?)?.trim() ?? 'Unnamed',
      gif: (data['gif'] as String?)?.trim() ?? '',
      equipment: (data['equipment'] as String?)?.trim() ?? 'None',
      target: (data['target'] as String?)?.trim() ?? 'Unknown',
      bodyPart: (data['bodyPart'] as String?)?.trim() ?? 'Unknown',
      duration: data['duration'] as int?,
      createdAt: (data['createdAt'] as Timestamp?)
          ?.toDate(), // Convert Firestore Timestamp
    );
  }
}
