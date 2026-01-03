import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/widgets/app_lifecycle_manager.dart';
import 'core/widgets/inactivity_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'features/totp/presentation/providers/totp_providers.dart'; // For search focus if needed

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  print('--- APP STARTING ---');
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('--- INITIALIZING FIREBASE ---');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('--- FIREBASE INITIALIZED ---');
  } catch (e, stack) {
    print('--- FIREBASE ERROR: $e ---');
    print(stack);
  }
  // Initialize WindowManager & HotKeyManager for Desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    await hotKeyManager.unregisterAll();
    
    // Global Shortcut: CTRL+SHIFT+A (Bring to Front)
    HotKey _hotKey = HotKey(
      key: PhysicalKeyboardKey.keyA, 
      modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );
    
    await hotKeyManager.register(
      _hotKey,
      keyDownHandler: (hotKey) async {
        await windowManager.show();
        await windowManager.focus();
        // Ideally focus search field here, but requires Ref or EventBus.
        // For now, bringing to front is the main productivity boost.
      },
    );
  }

  runApp(
    const ProviderScope(
      child: FidelyKeyApp(),
    ),
  );
}

class FidelyKeyApp extends StatelessWidget {
  const FidelyKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // KEY ADDED
      title: 'FidelyKey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
      builder: (context, child) {
        return InactivityWrapper(
          child: AppLifecycleManager(
            child: child!,
          ),
        );
      },
    );
  }
}
