import 'package:uuid/uuid.dart';
import '../../features/totp/domain/entities/totp_account.dart';

class OtpAuthParser {
  /// Parses a otpauth URI.
  /// Format: otpauth://totp/Label?secret=SECRET&issuer=Issuer&algorithm=SHA1&digits=6&period=30
  static TotpAccount? parse(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      if (uri.scheme != 'otpauth' || uri.host != 'totp') {
        return null;
      }

      final query = uri.queryParameters;
      final secret = query['secret'];
      if (secret == null) return null;

      // Label is usually path segment: /totp/Issuer:Account or /totp/Account
      String label = uri.pathSegments.isNotEmpty ? Uri.decodeComponent(uri.pathSegments.last) : 'Unknown';
      String issuer = query['issuer'] ?? '';
      String accountName = label;

      if (label.contains(':')) {
        final parts = label.split(':');
        if (issuer.isEmpty) issuer = parts[0].trim();
        accountName = parts[1].trim();
      } else if (issuer.isNotEmpty && label.startsWith('$issuer:')) {
         accountName = label.substring(issuer.length + 1).trim();
      }

      // Defaults
      final algorithm = query['algorithm'] ?? 'SHA1';
      final digits = int.tryParse(query['digits'] ?? '6') ?? 6;
      final period = int.tryParse(query['period'] ?? '30') ?? 30;

      return TotpAccount(
        id: const Uuid().v4(),
        secretKey: secret,
        accountName: accountName,
        issuer: issuer.isNotEmpty ? issuer : 'Unknown',
        algorithm: algorithm,
        digits: digits,
        period: period,
        // sortOrder default 0
      );
    } catch (e) {
      print('Error parsing OTP URI: $e');
      return null;
    }
  }
}
