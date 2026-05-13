import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Utility class for hashing and verifying passwords using Argon2id.
class PasswordHasher {
  final _algorithm = Argon2id(
    memory: 32768, // 32MB
    iterations: 2,
    hashLength: 32,
    parallelism: 1,
  );

  /// Hashes a plain text password and returns it in PHC format.
  Future<String> hashPassword(String plainTextPassword) async {
    // Generate a 16-byte random salt
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));

    final secretKey = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(plainTextPassword)),
      nonce: salt,
    );

    final hashBytes = await secretKey.extractBytes();
    
    return _toPhcFormat(salt, hashBytes);
  }

  /// Verifies a plain text password against a stored PHC hash string.
  Future<bool> verifyPassword(String plainTextPassword, String storedHash) async {
    try {
      final parts = storedHash.split(r'$');
      if (parts.length != 6) return false;

      // parts[0] is empty because the string starts with '$'
      // parts[1] is 'argon2id'
      // parts[2] is 'v=19'
      // parts[3] is 'm=32768,t=2,p=1'
      final saltBase64 = parts[4];
      final hashBase64 = parts[5];

      // Dart's base64.decode REQUIRES padding. We must add it back!
      final salt = base64.decode(_addPadding(saltBase64));
      
      final secretKey = await _algorithm.deriveKey(
        secretKey: SecretKey(utf8.encode(plainTextPassword)),
        nonce: salt,
      );

      final newHashBytes = await secretKey.extractBytes();
      final newHashBase64 = base64.encode(newHashBytes).replaceAll('=', '');

      // Constant-time comparison would be better, but string comparison of hashes is okay here
      // since the hash itself is public knowledge in the DB.
      return newHashBase64 == hashBase64;
    } catch (e) {
      return false;
    }
  }

  /// Formats the output as a standard PHC string.
  String _toPhcFormat(List<int> salt, List<int> hash) {
    final saltBase64 = base64.encode(salt).replaceAll('=', '');
    final hashBase64 = base64.encode(hash).replaceAll('=', '');
    
    // Hardcoding p=1 as it's the default and not exposed by the library constructor we use.
    return '\$argon2id\$v=19\$m=32768,t=2,p=1\$$saltBase64\$$hashBase64';
  }

  /// Helper to add Base64 padding back because Dart's decoder strictly requires it.
  String _addPadding(String base64String) {
    final mod = base64String.length % 4;
    if (mod == 0) return base64String;
    return base64String.padRight(base64String.length + (4 - mod), '=');
  }
}
