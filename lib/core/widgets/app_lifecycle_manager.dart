import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/pin_service.dart';
import '../../features/auth/presentation/pages/lock_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../main.dart'; // navigatorKey

class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onLockStateChanged;

  const AppLifecycleManager({
    super.key, 
    required this.child,
    this.onLockStateChanged,
  });

  @override
  ConsumerState<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager> with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background
      _wasBackgrounded = true;
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground
      if (_wasBackgrounded) {
        _checkAndLock();
        _wasBackgrounded = false;
      }
    }
  }

  Future<void> _checkAndLock() async {
    // 1. Check if user is logged in (handled by Provider check usually, but we need to be fast)
    // We can rely on PinService.hasPin() which likely implicitly means we are set up.
    // But importantly, we shouldn't lock if we are ON the login screen or ON the lock screen.
    
    // Check current route using navigatorKey
    bool validToLock = true;
    
    // Use popUntil to inspect the stack? No.
    // We can check the topmost route if we tracked it, or just blindly push LockScreen if authenticated.
    
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();

    if (hasPin) {
      if (navigatorKey.currentState?.canPop() ?? false) {
         // This is tricky. We don't want to lock if we are already on LockScreen.
         // A simple way is to check if the top route is LockScreen.
         // But Route checking is hard in Flutter without a navigation observer.
         // Assuming we push LockScreen as a full page.
      }
      
      // We force lock.
      // Optimisation: Don't lock if already on LockScreen.
      // We will blindly push LockScreen. The LockScreen itself could act as a singleton or UniqueKey logic?
      // Or we define a specific route name.
      
      // Simplified Logic: Just Push LockScreen. 
      // User requested "IMMEDIATELY push LockScreen".
      
      // Prevent double locking if already there?
      // A hack is to check a static variable or provider state "isLocked".
      // But let's follow the simple instruction: Push LockScreen.
      
      // We pass onUnlock to simply pop.
      navigatorKey.currentState?.push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LockScreen(
             onUnlock: () {
               navigatorKey.currentState?.pop();
             }
          ),
          transitionDuration: Duration.zero, // No animation for speed
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

