import 'dart:io';
import 'dart:ui'; // for ImageFilter
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

// ... imports ...

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager> with WidgetsBindingObserver {
  bool _wasBackgrounded = false;
  DateTime? _lastPausedTime;
  bool _showBlur = false; // Controls iOS Blur Overlay

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableSecureMode();
  }

  // Task 3: Enable Secure Mode (Android)
  Future<void> _enableSecureMode() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        debugPrint('Failed to add secure flag: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Task 3: iOS Blur Protection
    if (Platform.isIOS) {
       if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
         setState(() => _showBlur = true);
       } else if (state == AppLifecycleState.resumed) {
         setState(() => _showBlur = false);
       }
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background
      _wasBackgrounded = true;
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // App coming to foreground
      
      // CRITICAL FIX: Ignore if we are currently authenticating (biometric dialog)
      if (AppLifecycleManager.isAuthenticating) {
        debugPrint('AppLifecycleManager: Ignoring resume because authentication is in progress.');
        return;
      }

      if (_wasBackgrounded && _lastPausedTime != null) {
        // CRITICAL FIX: Ignore short interruptions (< 500ms) like FaceID dialogs
        final duration = DateTime.now().difference(_lastPausedTime!);
        if (duration.inMilliseconds < 500) {
           debugPrint('AppLifecycleManager: Short pause detected (${duration.inMilliseconds}ms), ignoring lock.');
           _wasBackgrounded = false;
           _lastPausedTime = null;
           return;
        }

        _checkAndLock();
        _wasBackgrounded = false;
        _lastPausedTime = null;
      }
    }
  }

  // ... _checkAndLock ...

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Privacy Blur Overlay (iOS mostly)
        if (_showBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.1),
                child: const Center(
                  child: Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

