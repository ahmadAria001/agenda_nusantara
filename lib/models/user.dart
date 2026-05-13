/// Data model representing a row in the `users` table.
class User {
  final int? id;
  final String username;
  final String password;

  const User({
    this.id,
    required this.username,
    required this.password,
  });

  /// Creates a [User] instance from a SQLite row map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  /// Converts this [User] into a map suitable for SQLite insertion.
  /// The `id` field is intentionally excluded so that SQLite can
  /// auto-generate it via AUTOINCREMENT.
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() => 'User(id: $id, username: $username)';
}
