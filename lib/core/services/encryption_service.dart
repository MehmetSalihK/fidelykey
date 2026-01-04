import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart' as pc; // Access via transitive dependency if possible, or use explicit PBKDF2
// If pointycastle is not directly accessible, we might need to rely on 'encrypt' or raw implementation.
// safely assuming 'encrypt' brings in enough tools, but for PBKDF2 let's use a robust standard approach.

class EncryptionService {
  // Constants
  static const int _iterationCount = 10000;
  static const int _keyLength = 32; // 256 bits

  /// Derives a secure key from the user's password using PBKDF2
  /// [salt] must be unique and stored with the encrypted data.
  static Uint8List deriveKey(String password, Uint8List salt) {
    // Using PointyCastle's PBKDF2
    final pc.KeyDerivator derivator = pc.KeyDerivator("SHA-256/HMAC/PBKDF2");
    final pc.Pbkdf2Parameters params = pc.Pbkdf2Parameters(salt, _iterationCount, _keyLength);
    
    derivator.init(params);
    return derivator.process(utf8.encode(password));
  }

  /// Encrypts a plain text string (JSON payload) using the derived key.
  /// Returns a Base64 encoded JSON string containing {iv, salt, data}
  static String encryptPayload(String jsonPayload, String password) {
    // 1. Generate random Salt and IV
    final salt = enc.IV.fromSecureRandom(16).bytes;
    final iv = enc.IV.fromSecureRandom(16);

    // 2. Derive Key
    final keyBytes = deriveKey(password, salt);
    final key = enc.Key(keyBytes);

    // 3. Encrypt (AES-GCM is preferred for integrity, but CBC is standard in 'encrypt' package simple usage. Let's use AES-CBC with PKCS7)
    // AES-GCM is better but 'encrypt' package's AES mode defaults often to CBC or SIC.
    // Let's explicitly use AES Mode CBC.
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonPayload, iv: iv);

    // 4. Pack everything
    final result = {
      'salt': base64Encode(salt),
      'iv': iv.base64,
      'data': encrypted.base64,
      'version': '1', // Future proofing
    };

    return base64Encode(utf8.encode(jsonEncode(result)));
  }

  /// Decrypts the blob using the password.
  static String decryptPayload(String encryptedBlob, String password) {
    try {
      // 1. Decode Blob
      final jsonStr = utf8.decode(base64Decode(encryptedBlob));
      final Map<String, dynamic> parts = jsonDecode(jsonStr);

      final salt = base64Decode(parts['salt']);
      final iv = enc.IV.fromBase64(parts['iv']);
      final cipherText = enc.Encrypted.fromBase64(parts['data']);

      // 2. Derive Key
      final keyBytes = deriveKey(password, salt);
      final key = enc.Key(keyBytes);

      // 3. Decrypt
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt(cipherText, iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: Incorrect Password or Corrupted Data');
    }
  }
}
