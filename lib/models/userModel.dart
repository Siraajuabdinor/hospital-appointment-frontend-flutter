import 'package:fluter/models/doctorModel.dart';

class UserModel {
  String id;
  String fullName;
  String email;
  String role;
  String? image;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      if (image != null) 'image': image,
    };
  }

  Doctor toDoctor() {
    return Doctor(
      id: id,
      fullName: fullName,
      email: email,
      tell: '', // Haddii backend-ka uusan soo dirin
      sex: '',
      qualification: '',
      experienceYears: 0,
      bio: '',
      image: image,
      status: 'active',
      sp_no: '',
    );
  }
}
