// Clean enum model to replace fragile bodyPart strings
enum BodyPart {
  upperBody,
  lowerBody,
  arms,
  shoulders,
  back,
  fullBody,
  cardio, // ✅ Added cardio here
  unknown,
}

extension BodyPartExtension on BodyPart {
  static BodyPart fromRaw(String raw) {
    final cleaned = raw.trim().toLowerCase();
    switch (cleaned) {
      case 'upper':
      case 'upper body':
      case 'upperbody':
        return BodyPart.upperBody;
      case 'lower':
      case 'legs':
      case 'lower body':
        return BodyPart.lowerBody;
      case 'arms':
      case 'biceps':
      case 'triceps':
        return BodyPart.arms;
      case 'shoulders':
        return BodyPart.shoulders;
      case 'back':
        return BodyPart.back;
      case 'full':
      case 'full body':
        return BodyPart.fullBody;
      case 'cardio': // ✅ Handle raw cardio inputs too
        return BodyPart.cardio;
      default:
        return BodyPart.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case BodyPart.upperBody:
        return 'Upper Body';
      case BodyPart.lowerBody:
        return 'Lower Body';
      case BodyPart.arms:
        return 'Arms';
      case BodyPart.shoulders:
        return 'Shoulders';
      case BodyPart.back:
        return 'Back';
      case BodyPart.fullBody:
        return 'Full Body';
      case BodyPart.cardio: // ✅ Show Cardio in dropdown
        return 'Cardio';
      case BodyPart.unknown:
      default:
        return 'Unknown';
    }
  }
}
