import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'login_screen.dart';
import '../../../../core/theme/app_theme.dart';

class QrLoginScreen extends ConsumerStatefulWidget {
  const QrLoginScreen({super.key});

  @override
  ConsumerState<QrLoginScreen> createState() => _QrLoginScreenState();
}

class _QrLoginScreenState extends ConsumerState<QrLoginScreen> with SingleTickerProviderStateMixin {
  String? _requestId;
  StreamSubscription<DocumentSnapshot>? _subscription;
  bool _isApproved = false;
  String? _approvedEmail;

  // Rotation Logic
  late AnimationController _timerController;
  final int _rotationInterval = 30; // Seconds

  @override
  void initState() {
    super.initState();
    // Animation Controller for the progress bar (and timer)
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _rotationInterval),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isApproved) {
        // Time's up -> Rotate
        _generateNewCode();
      }
    });

    // Start first cycle
    _generateNewCode();
  }

  @override
  void dispose() {
    _cleanupOldRequest(); // Delete current doc on exit
    _timerController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  /// Cleans up the previous/current request from Firestore
  void _cleanupOldRequest() {
    final oldId = _requestId;
    if (oldId != null && !_isApproved) {
      // Fire and forget delete
      FirebaseFirestore.instance.collection('auth_requests').doc(oldId).delete();
    }
  }

  Future<void> _generateNewCode() async {
    if (!mounted) return;

    // 1. Cleanup previous
    _cleanupOldRequest();
    _subscription?.cancel();

    // 2. Generate New ID
    final uuid = const Uuid().v4();
    
    // 3. Create Doc
    final docRef = FirebaseFirestore.instance.collection('auth_requests').doc(uuid);
    await docRef.set({
      'requestId': uuid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'platform': 'PC/Web',
      'expiresAt': DateTime.now().add(Duration(seconds: _rotationInterval)).toIso8601String(),
    });

    if (!mounted) return;

    setState(() {
      _requestId = uuid;
    });

    // 4. Start Listen
    _subscription = docRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;

      final status = data['status'] as String?;
      if (status == 'approved') {
        final email = data['email'] as String?;
        if (email != null) {
          _handleApproval(email);
        }
      }
    });

    // 5. Restart Timer
    _timerController.reset();
    _timerController.forward();
  }

  void _handleApproval(String email) {
    if (_isApproved) return; // Already handled
    
    // Stop rotation
    _timerController.stop();
    _subscription?.cancel();
    
    // Update State
    setState(() {
      _isApproved = true;
      _approvedEmail = email;
    });

    // Clean up doc immediately to prevent reuse (optional, or keep for logs)
    if (_requestId != null) {
       FirebaseFirestore.instance.collection('auth_requests').doc(_requestId).delete();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appareil détecté ! Redirection...')),
    );

    // Initial Delay for UX
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      // Navigate to Login with Email Pre-filled
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: _approvedEmail),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion par QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isApproved)
               Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.check_circle, color: Colors.green, size: 80),
                   const SizedBox(height: 16),
                   Text(
                     'Compte trouvé !', 
                     style: Theme.of(context).textTheme.headlineSmall,
                   ),
                   const SizedBox(height: 8),
                   Text(_approvedEmail ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                 ],
               )
            else if (_requestId == null)
              const CircularProgressIndicator()
            else ...[
                // QR Display with Animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey<String>(_requestId!), // Triggers animation on ID change
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.1),
                           blurRadius: 20,
                           spreadRadius: 5,
                         )
                      ],
                    ),
                    child: QrImageView(
                      data: 'fidely-login:$_requestId',
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Instructions
                const Text(
                  'Scannez avec votre mobile connecté',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Le code change toutes les 30s pour votre sécurité',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),
                
                // Progress Bar
                SizedBox(
                  width: 200,
                  child: AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1.0 - _timerController.value, // Countdown
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
