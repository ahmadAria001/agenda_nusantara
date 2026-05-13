import '../helpers/database_helper.dart';
import '../models/user.dart';
import '../utils/password_hasher.dart';
import 'auth_repository.dart';

/// Concrete implementation of [AuthRepositoryBase] backed by SQLite.
class AuthRepositoryImpl implements AuthRepositoryBase {
  final DatabaseHelper _dbHelper;
  final PasswordHasher _passwordHasher;

  AuthRepositoryImpl({DatabaseHelper? dbHelper, PasswordHasher? passwordHasher})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _passwordHasher = passwordHasher ?? PasswordHasher();

  @override
  Future<User?> login(String username, String password) async {
    final user = await _dbHelper.getUserByUsername(username);
    if (user == null) return null;

    final isValid = await _passwordHasher.verifyPassword(password, user.password);
    if (!isValid) return null;

    return user;
  }

  @override
  Future<bool> updatePassword(
    String username,
    String oldPassword,
    String newPassword,
  ) async {
    // First verify the old password is correct
    final user = await _dbHelper.getUserByUsername(username);
    if (user == null) return false;

    final isValid = await _passwordHasher.verifyPassword(oldPassword, user.password);
    if (!isValid) return false;

    // Hash the new password
    final newHash = await _passwordHasher.hashPassword(newPassword);

    final rowsAffected = await _dbHelper.updatePassword(username, newHash);
    return rowsAffected > 0;
  }
}
