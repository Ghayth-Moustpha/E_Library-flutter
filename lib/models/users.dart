class User {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }
}
