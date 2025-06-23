// lib/models/user_model.dart

class User {
  final String id;
  final String? name;
  final String email;
  final List<String> roles;
  // Añade otros campos que necesites, como 'avatarUrl', etc.

  User({required this.id, this.name, required this.email, required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'roles': roles};
  }
}
