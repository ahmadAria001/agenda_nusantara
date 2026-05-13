import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';

/// Manages authentication state and exposes it to the widget tree
/// via [ChangeNotifier] (Provider pattern).
///
/// Follows SRP: this class handles *only* auth-related state.
class AuthController extends ChangeNotifier {
  final AuthRepositoryBase _repository;

  AuthController({required AuthRepositoryBase repository})
      : _repository = repository;

  // ── State ──────────────────────────────────────────────────────────────
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────

  /// Attempts login. Updates [currentUser] on success, sets [errorMessage]
  /// on failure.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(username, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Changes the password for the currently logged-in user.
  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) {
      _errorMessage = 'Tidak ada pengguna yang login';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.updatePassword(
        _currentUser!.username,
        oldPassword,
        newPassword,
      );

      if (success) {
        // Update the in-memory user with the new password
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          password: newPassword,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Password lama tidak sesuai';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs the user out and resets state.
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears any active error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
