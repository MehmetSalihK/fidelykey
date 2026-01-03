import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/pin_service.dart';

// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StreamProvider for Auth State (User or Null)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// FutureProvider to check if PIN is set
// Usage: ref.watch(pinHasPinProvider)
final pinHasPinProvider = FutureProvider<bool>((ref) async {
  final pinService = ref.watch(pinServiceProvider);
  return await pinService.hasPin();
});
