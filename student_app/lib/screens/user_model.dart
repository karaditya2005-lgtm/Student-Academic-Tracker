// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String studentClass;
  final String rollNumber;
  final String school;
  final String avatarInitials;
  final DateTime registeredAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentClass,
    required this.rollNumber,
    required this.school,
    required this.avatarInitials,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'studentClass': studentClass,
        'rollNumber': rollNumber,
        'school': school,
        'avatarInitials': avatarInitials,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'],
        name: json['name'],
        email: json['email'],
        studentClass: json['studentClass'] ?? '',
        rollNumber: json['rollNumber'] ?? '',
        school: json['school'] ?? '',
        avatarInitials: json['avatarInitials'] ?? '',
        registeredAt: DateTime.parse(json['registeredAt']),
      );
}
