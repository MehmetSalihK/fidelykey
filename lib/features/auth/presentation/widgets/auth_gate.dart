import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_lifecycle_manager.dart';
import '../providers/auth_provider.dart';
import '../pages/login_screen.dart';
import '../pages/lock_screen.dart';
import '../pages/create_pin_screen.dart';
import '../../../home/presentation/pages/main_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isLocked = true; // Default to locked when authenticated

  void _updateLockState(bool isLocked) {
    setState(() => _isLocked = isLocked);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final pinCheck = ref.watch(pinHasPinProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        } 
        
        // User is logged in, check for PIN
        return pinCheck.when(
          data: (hasPin) {
            if (!hasPin) {
              return const CreatePinScreen();
            }
            // Has PIN -> Standard security flow
            return AppLifecycleManager(
              onLockStateChanged: _updateLockState,
              child: _isLocked
                  ? LockScreen(onUnlock: () => _updateLockState(false))
                  : const MainScreen(),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text('Erreur PIN: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(body: Center(child: Text('Erreur Auth: $e'))),
    );
  }
}
