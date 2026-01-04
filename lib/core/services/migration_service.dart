import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otpauth_migration/otpauth_migration.dart';
import 'package:uuid/uuid.dart';

import '../../features/totp/domain/entities/totp_account.dart';
import '../../features/totp/data/repositories/totp_repository.dart';
import 'audit_service.dart';

final migrationServiceProvider = Provider((ref) => MigrationService(ref));

class MigrationService {
  final Ref _ref;
  final OtpAuthMigration _decoder = OtpAuthMigration();
  final Uuid _uuid = const Uuid();

  MigrationService(this._ref);

  /// Imports accounts from a Google Authenticator Migration QR Code URL.
  /// Returns the number of accounts successfully imported.
  Future<int> importFromGoogleQr(String migrationUrl) async {
    if (!migrationUrl.startsWith('otpauth-migration://')) {
      throw const FormatException('Format QR Code invalide (attendu: otpauth-migration://)');
    }

    try {
      // 1. Decode Protobuf Data
      final List<String> otpAuthUris = _decoder.decode(migrationUrl);
      
      if (otpAuthUris.isEmpty) return 0;

      int importedCount = 0;
      final repo = _ref.read(totpRepositoryProvider);

      // 2. Parse each otpauth:// URI
      for (final uriString in otpAuthUris) {
        final uri = Uri.parse(uriString);
        
        if (uri.scheme != 'otpauth') continue;

        // Path is usually /Type/Label or just /Label
        // Google often formats it "otpauth://totp/Issuer:Account?..."
        
        final pathSegments = uri.pathSegments;
        if (pathSegments.isEmpty) continue;
        
        // Extract Label (Issuer:AccountName)
        String label = Uri.decodeComponent(pathSegments.last);
        String? issuer = uri.queryParameters['issuer'];
        final secret = uri.queryParameters['secret'];
        final algorithm = uri.queryParameters['algorithm'] ?? 'SHA1';
        final digits = int.tryParse(uri.queryParameters['digits'] ?? '6') ?? 6;
        final period = int.tryParse(uri.queryParameters['period'] ?? '30') ?? 30;

        if (secret == null) continue;

        // Clean Label
        String accountName = label;
        if (label.contains(':')) {
           final parts = label.split(':');
           if (issuer == null || issuer.isEmpty) issuer = parts.first.trim();
           // Remove issuer from label to get pure account name
           if (parts.length > 1) accountName = parts.sublist(1).join(':').trim();
        }

        // 3. Create Entity
        final newAccount = TotpAccount(
          id: _uuid.v4(),
          secret: secret,
          accountName: accountName,
          issuer: issuer ?? 'Unknown',
          algorithm: algorithm,
          digits: digits,
          period: period,
          createdAt: DateTime.now(),
        );

        // 4. Save
        await repo.addAccount(newAccount);
        importedCount++;
      }

      _ref.read(auditServiceProvider).log('IMPORT', 'Imported $importedCount accounts from Google Auth');
      return importedCount;

    } catch (e) {
      _ref.read(auditServiceProvider).log('IMPORT_ERROR', e.toString());
      throw Exception('Erreur lors du décodage: $e');
    }
  }
}
