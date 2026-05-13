import '../models/user.dart';

/// Abstract contract for authentication operations (DIP).
///
/// The UI and state-management layers depend on this interface,
/// never on the concrete [DatabaseHelper] directly.
abstract class AuthRepositoryBase {
  /// Attempts to log in with [username] and [password].
  /// Returns the authenticated [User] on success, or `null` on failure.
  Future<User?> login(String username, String password);

  /// Changes the password for the currently logged-in [username].
  /// [oldPassword] must match the existing record.
  /// Returns `true` if the update succeeded, `false` otherwise.
  Future<bool> updatePassword(
    String username,
    String oldPassword,
    String newPassword,
  );
}
