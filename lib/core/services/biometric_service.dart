import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Vérifie si le matériel biométrique est disponible.
  Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      print('Erreur Biomeriaque (Check): $e');
      return false;
    }
  }

  /// Tente d'authentifier l'utilisateur.
  /// Retourne `true` si succès, `false` sinon.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à FidelyKey',
      );
    } on PlatformException catch (e) {
      print('Erreur Biometrique (Auth): $e');
      return false;
    }
  }
}
