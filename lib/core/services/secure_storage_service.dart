import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service gérant le stockage sécurisé des données sensibles.
/// Utilise `flutter_secure_storage` avec les meilleures options de sécurité pour chaque plateforme.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  /// Sauvegarde une chaine de caractères de manière sécurisée.
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      // En production, logger l'erreur via un service de Crashlytics.
      print('Erreur SecureStorage (write): $e');
      rethrow;
    }
  }

  /// Récupère une chaine de caractères déchiffrée.
  /// Retourne `null` si la clé n'existe pas.
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('Erreur SecureStorage (read): $e');
      rethrow;
    }
  }

  /// Supprime une entrée spécifique.
  Future<void> deleteString(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Erreur SecureStorage (delete): $e');
      rethrow;
    }
  }

  /// Supprime TOUTES les données (Attention: irréversible).
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Erreur SecureStorage (deleteAll): $e');
      rethrow;
    }
  }
}
