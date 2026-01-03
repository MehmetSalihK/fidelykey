import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../main.dart'; // To access navigatorKey

class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const InactivityWrapper({
    super.key, 
    required this.child, 
    this.timeout = const Duration(minutes: 15),
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, _handleTimeout);
  }

  void _resetTimer() {
    if (kIsWeb) {
      _startTimer();
    }
  }

  Future<void> _handleTimeout() async {
    // Only logout if user is actually signed in
    if (FirebaseAuth.instance.currentUser != null) {
      print('--- SESSION TIMEOUT (Web) ---');
      await FirebaseAuth.instance.signOut();
      
      // Redirect to Login
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      
      // Optional: Show feedback
      // Since context might be tricky here, we rely on the redirect.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerHover: (_) => _resetTimer(),
      child: MouseRegion(
        onHover: (_) => _resetTimer(),
        child: widget.child,
      ),
    );
    // Note: KeyboardListener could be added too, but Listener covers most interactions.
    // Ideally we would wrap with specific Focus node for keyboard, but Listener onPointerDown covers clicks.
  }
}
