// UserModel: Represents a basic authenticated user in the app
class UserModel {
  final String uid; // Firebase User ID
  final String email; // User email address

  // Constructor to create a UserModel instance
  UserModel({
    required this.uid,
    required this.email,
  });

  // Factory method: Creates UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
    );
  }

  // Converts UserModel instance into JSON format
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
    };
  }
}
/*
user_model.dart:
Defines the UserModel class for representing authenticated users.
Includes fromJson() and toJson() for Firebase-compatible data mapping.
Used during sign-in/sign-up to save & fetch user info cleanly.
*/
