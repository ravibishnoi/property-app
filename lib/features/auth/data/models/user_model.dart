import '../../domain/entities/app_user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role,
    );
  }
}
