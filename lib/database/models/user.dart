class User {
  int? id;
  String email;
  String passwordHash;
  String name;
  DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['passwordHash'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}