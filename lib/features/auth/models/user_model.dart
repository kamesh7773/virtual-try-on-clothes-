import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final int? id;
  final String? email;
  final String? name;
  final String? role;
  final String? avatar;

  const UserModel({
    this.id,
    this.email,
    this.name,
    this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int?,
        email: json['email'] as String?,
        name: json['name'] as String?,
        role: json['role'] as String?,
        avatar: json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (avatar != null) 'avatar': avatar,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          role == other.role &&
          avatar == other.avatar;

  @override
  int get hashCode => Object.hash(id, email, name, role, avatar);
}
