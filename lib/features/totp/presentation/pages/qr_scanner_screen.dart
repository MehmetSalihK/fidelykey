import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../../core/utils/otp_auth_parser.dart';
import '../providers/totp_providers.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        // DETECT LOGIN QR
        if (code.startsWith('fidely-login:')) {
          _handleLoginRequest(code);
          return; // Stop processing this capture
        }
        
        // STANDARD TOTP (otpauth://)
        final uri = code; // Use the raw code directly for parsing
        final account = OtpAuthParser.parse(uri);
        
        if (account != null) {
          setState(() => _isProcessing = true);
          // Pause camera to freeze frame
          controller.stop();
          
          // Save and pop
          ref.read(accountsProvider.notifier).addAccount(
            secret: account.secretKey,
            name: account.accountName,
            issuer: account.issuer ?? '',
            algorithm: account.algorithm,
            digits: account.digits,
            period: account.period,
          ).then((_) {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Compte ajouté : ${account.issuer}')),
               );
               Navigator.of(context).pop();
             }
          });
          break; 
        } else {
          // Invalid format feedback? 
          // If we want to be strict, we can show error.
          // But typically we just ignore non-OTP QR codes to avoid spamming errors on random QRs.
          // User requested: "Affiche une SnackBar d'erreur et reprend le scan"
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('QR Code invalide ou non supporté (otpauth:// requis)'),
               duration: Duration(seconds: 2),
             )
          );
        }
      }
    }
  }

  // Handle Login Request
  Future<void> _handleLoginRequest(String code) async {
    controller.stop(); // Pause scanning
    final requestId = code.replaceAll('fidely-login:', '');
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connexion PC détectée'),
        content: const Text('Voulez-vous autoriser la connexion sur cet appareil ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Refuser')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('AUTORISER')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || user.email == null) throw 'Utilisateur non identifié';

        await FirebaseFirestore.instance.collection('auth_requests').doc(requestId).update({
          'status': 'approved',
          'email': user.email,
          'uid': user.uid,
          'approvedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion autorisée !')));
           Navigator.pop(context); // Close scanner
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
           controller.start(); // Resume
        }
      }
    } else {
      controller.start(); // Resume on cancel
    }
  }

  @override
  Widget build(BuildContext context) {
    // Overlay Style
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 250,
      height: 250,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    Text('Erreur Caméra: ${error.errorCode}'),
                  ],
                ),
              );
            },
          ),
          
          // Dark Overlay with Cutout (Custom Paint or Container/Stack trick)
          // Using a simple ColoredBox with BlendMode is tricky. 
          // Simplest is a Stack of 4 semi-transparent boxes around the center hole.
          _buildOverlay(context, scanWindow),

          // Border for the scan window
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isProcessing 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, Rect scanWindow) {
    final size = MediaQuery.of(context).size;
    final color = Colors.black.withOpacity(0.6);

    return Stack(
      children: [
        // Top
        Positioned(
          top: 0, left: 0, right: 0,
          height: scanWindow.top,
          child: Container(color: color),
        ),
        // Bottom
        Positioned(
          top: scanWindow.bottom, left: 0, right: 0,
          bottom: 0,
          child: Container(color: color),
        ),
        // Left
        Positioned(
          top: scanWindow.top, left: 0,
          width: scanWindow.left, height: scanWindow.height,
          child: Container(color: color),
        ),
        // Right
        Positioned(
          top: scanWindow.top, left: scanWindow.right,
          right: 0, height: scanWindow.height,
          child: Container(color: color),
        ),
      ],
    );
  }
}
