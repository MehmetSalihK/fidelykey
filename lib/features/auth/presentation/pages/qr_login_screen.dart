import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

// ... imports ...

  // Helper to get Device Name
  Future<String> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName = 'PC Client';

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceName = '${webInfo.browserName.name} (${webInfo.platform})';
      } else if (Platform.isWindows) {
        final winInfo = await deviceInfo.windowsInfo;
        deviceName = 'Windows ${winInfo.majorVersion}'; // e.g. Windows 10
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceName = 'Mac ${macInfo.computerName}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceName = 'Linux ${linuxInfo.name}';
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    return deviceName;
  }

  Future<void> _generateNewCode() async {
    if (!mounted) return;

    // 1. Cleanup previous
    _cleanupOldRequest();
    _subscription?.cancel();

    // 2. Generate New ID
    final uuid = const Uuid().v4();
    print('DEBUG PC: Génération nouveau code: $uuid');
    
    // 3. Get Device Info
    final deviceInfo = await _getDeviceInfo(); // NEW
    
    // 4. Create Doc
    final docRef = FirebaseFirestore.instance.collection('auth_requests').doc(uuid);
    
    try {
      print('DEBUG PC: Tentative de création du document Firestore...');
      await docRef.set({
        'requestId': uuid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'PC/Web',
        'deviceInfo': deviceInfo, // NEW
        'expiresAt': DateTime.now().add(Duration(seconds: _rotationInterval)).toIso8601String(),
      });
      print('DEBUG PC: Document créé avec succès.');
    } catch (e) {
      // ... error handling ...
      print('DEBUG PC CLOUD ERROR: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           content: Text('Erreur Firestore (PC): $e'), backgroundColor: Colors.red,
         ));
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _requestId = uuid;
    });

    // ... listening logic ...
    print('DEBUG PC: Écoute des changements sur $uuid...');
    _subscription = docRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
         print('DEBUG PC: Doc supprimé ou inexistant.');
         return;
      }
      final data = snapshot.data();
      if (data == null) return;

      final status = data['status'] as String?;
      print('DEBUG PC: Changement statut détecté -> $status');

      if (status == 'approved') {
        final email = data['email'] as String?;
        print('DEBUG PC: APPROUVÉ ! Email reçu: $email');
        if (email != null) {
          _handleApproval(email);
        }
      }
    }, onError: (e) {
       print('DEBUG PC STREAM ERROR: $e');
    });

    // ... timer logic ...
    _timerController.reset();
    _timerController.forward();
  }

  // ... _handleApproval ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access TextTheme and Colors

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion par QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isApproved)
               // ... existing success UI ...
               Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.check_circle, color: Colors.green, size: 80),
                   const SizedBox(height: 16),
                   Text(
                     'Compte trouvé !', 
                     style: theme.textTheme.headlineSmall,
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
                    key: ValueKey<String>(_requestId!),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                         BoxShadow(
                           color: theme.colorScheme.primary.withOpacity(0.2), // Colored shadow
                           blurRadius: 30,
                           spreadRadius: 5,
                         )
                      ],
                    ),
                    child: QrImageView(
                      data: 'fidely-login:$_requestId',
                      version: QrVersions.auto,
                      size: 260.0,
                      // STYLED QR CODE
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.8), // Slightly lighter?
                      ),
                      // EMBEDDED IMAGE
                      embeddedImage: const AssetImage('lib/assets/icon/logo.png'), 
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(50, 50),
                      ),
                      errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction for logo
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Instructions
                Text(
                  'Scannez avec votre mobile',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Code sécurisé unique',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                // ...
            ],
          ],
        ),
      ),
    );
  }
}
