import '../../../../core/services/biometric_service.dart';

  // ... imports ...

  // Handle Login Request
  Future<void> _handleLoginRequest(String code) async {
    print('DEBUG MOBILE: QR Scan détecté: $code');
    controller.stop(); // Pause scanning
    final requestId = code.replaceAll('fidely-login:', '');
    print('DEBUG MOBILE: RequestID extrait: $requestId');

    try {
      // 1. Fetch Request Info (to know WHO is asking)
      final docSnapshot = await FirebaseFirestore.instance.collection('auth_requests').doc(requestId).get();
      
      if (!docSnapshot.exists) throw 'Demande expirée ou invalide';
      final data = docSnapshot.data();
      final deviceInfo = data?['deviceInfo'] ?? 'Appareil Inconnu';
      
      // 2. Show Confirmation Dialog
      if (!mounted) return;
      
      final confirm = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               const Icon(Icons.laptop_mac_rounded, size: 64, color: Colors.blueAccent),
               const SizedBox(height: 16),
               Text(
                 'Nouvelle Connexion', 
                 style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
               ),
               const SizedBox(height: 8),
               Text(
                 'Voulez-vous connecter cet appareil ?',
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.grey),
               ),
               const SizedBox(height: 16),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.grey.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.devices, size: 20, color: Colors.grey),
                     const SizedBox(width: 8),
                     Text(deviceInfo, style: const TextStyle(fontWeight: FontWeight.w600)),
                   ],
                 ),
               ),
               const SizedBox(height: 32),
               Row(
                 children: [
                   Expanded(
                     child: OutlinedButton(
                       onPressed: () => Navigator.pop(ctx, false),
                       style: OutlinedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                       ),
                       child: const Text('Refuser', style: TextStyle(color: Colors.red)),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: FilledButton(
                       onPressed: () => Navigator.pop(ctx, true),
                       style: FilledButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         backgroundColor: Colors.green,
                       ),
                       child: const Text('CONFIRMER'),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
            ],
          ),
        ),
      );

      if (confirm != true) {
         print('DEBUG MOBILE: Refusé par utilisateur');
         controller.start();
         return;
      }

      // 3. BIOMETRIC SECURITY CHECK
      final bioService = BiometricService();
      final authenticated = await bioService.authenticate();
      
      if (!authenticated) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentification requise')));
         controller.start();
         return;
      }

      // 4. Update Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
          throw 'Utilisateur non identifié';
      }

      print('DEBUG MOBILE: Tentative update Firestore...');
      await FirebaseFirestore.instance.collection('auth_requests').doc(requestId).update({
        'status': 'approved',
        'email': user.email,
        'uid': user.uid,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedByDevice': 'Mobile Scanner', 
      });
      print('DEBUG MOBILE: Update Firestore RÉUSSIE !');

      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion autorisée !')));
          Navigator.pop(context); // Close scanner
      }

    } catch (e) {
      print('DEBUG MOBILE EXCEPTION: $e');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
          controller.start(); // Resume
      }
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
