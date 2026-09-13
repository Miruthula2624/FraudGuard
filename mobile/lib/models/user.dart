class User {
  final int id;
  final String username;
  final String email;

  const User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}
