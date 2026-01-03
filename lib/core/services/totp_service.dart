import 'package:otp/otp.dart';
import 'package:base32/base32.dart';

/// Service responsable de la génération des codes TOTP (Time-based One-Time Password).
/// Implémente la RFC 6238.
class TotpService {
  /// Génère un code TOTP actuel.
  ///
  /// [secret] : La clé secrète (peut être en Base32).
  /// [interval] : La période de validité (défaut 30s).
  /// [digits] : Le nombre de chiffres (défaut 6).
  /// [algorithm] : L'algorithme de hachage (SHA1, SHA256...). Pour l'instant supporte SHA1 par défaut.
  String generateCode(
    String secret, {
    int interval = 30,
    int digits = 6,
    String algorithm = 'SHA1',
    DateTime? now, // Optional override for testing or manual time
  }) {
    // Nettoyage du secret (suppression espaces)
    String cleanSecret = secret.replaceAll(' ', '').toUpperCase();

    try {
      final validNow = now ?? DateTime.now(); // We will inject TimeService in Provider
      final nowMs = validNow.millisecondsSinceEpoch;
      
      // Mapping de l'algorithme
      Algorithm algo = Algorithm.SHA1;
      if (algorithm == 'SHA256') algo = Algorithm.SHA256;
      if (algorithm == 'SHA512') algo = Algorithm.SHA512;

      return OTP.generateTOTPCodeString(
        cleanSecret,
        nowMs,
        length: digits,
        interval: interval,
        algorithm: algo,
        isGoogle: true, // Suppose que le secret est en Base32 (standard industriel)
      );
    } catch (e) {
      // En cas d'erreur (ex: secret malformé), on retourne une erreur ou 000000
      print('Erreur TotpService: $e');
      return '000000';
    }
  }

  /// Vérifie si un secret est valide (Base32).
  bool isValidSecret(String secret) {
    try {
      base32.decode(secret.replaceAll(' ', '').toUpperCase());
      return true;
    } catch (_) {
      return false;
    }
  }
}
