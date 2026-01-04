import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/services/pin_service.dart';
import '../../../totp/presentation/providers/totp_providers.dart';
import '../providers/auth_provider.dart';
import '../pages/create_pin_screen.dart'; // Import for redirection
import '../pages/login_screen.dart'; // Import for Logout
import '../../../../core/widgets/app_lifecycle_manager.dart'; // Import for isAuthenticating flag


class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlock;

  const LockScreen({super.key, required this.onUnlock});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> with SingleTickerProviderStateMixin {
  final BiometricService _biometricService = BiometricService();
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // State
  String _inputPin = '';
  bool _isAuthenticating = false;
  bool _isLockedOut = false;
  String? _statusMessage;
  bool _showPinPad = false; // Toggle for Mobile

  // Animations
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _shakeController.reset();
            setState(() => _inputPin = ''); // Clear PIN after shake
          }
        });

    _checkPlatformAndSettings();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _checkPlatformAndSettings() async {
    // Logic: Desktop -> Always PIN Pad. Mobile -> Bio first, then PIN.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
       WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometricInit());
    } else {
       setState(() => _showPinPad = true);
    }
  }

  Future<void> _checkBiometricInit() async {
    final storage = ref.read(secureStorageServiceProvider);
    final enabledStr = await storage.getString('biometrics_enabled');
    if (enabledStr != 'false') {
      _authenticateBiometrics();
    } else {
      setState(() => _showPinPad = true); // Fallback if disabled
    }
  }

  Future<void> _authenticateBiometrics() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    // Protection: Signal that we are intentionally invoking a system dialog
    // This prevents AppLifecycleManager from locking the app when we return.
    AppLifecycleManager.isAuthenticating = true;

    try {
      final authenticated = await _biometricService.authenticate();
      
      if (mounted) {
        if (authenticated) {
          _unlock();
        } else {
          setState(() {
             _statusMessage = 'Biométrie échouée';
             _showPinPad = true; 
          });
        }
      }
    } finally {
      // Always reset the flag, even if auth crashes
      AppLifecycleManager.isAuthenticating = false;
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _onKeyTap(String value) {
    if (_inputPin.length < 4 && !_isAuthenticating) {
      setState(() {
        _inputPin += value;
        _statusMessage = null;
      });
      if (_inputPin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onBackspace() {
    if (_inputPin.isNotEmpty) {
      setState(() => _inputPin = _inputPin.substring(0, _inputPin.length - 1));
    }
  }

  Future<void> _validatePin() async {
    setState(() => _isAuthenticating = true);
    // Simulate slight delay for UX (feeling of "processing security")
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final status = await ref.read(pinServiceProvider).verifyPin(_inputPin);
      
      if (status == PinStatus.success) {
        ref.read(duressModeProvider.notifier).deactivate();
        _unlock();
      } else if (status == PinStatus.duress) {
        ref.read(duressModeProvider.notifier).activate();
        ref.read(auditServiceProvider).log('SECURITY', 'DURESS PIN USED');
        _unlock(); // Unlock into empty dashboard
      } else {
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
            _statusMessage = 'Code Incorrect';
          });
          _shakeController.forward(); // Trigger Error Animation
          ref.read(auditServiceProvider).log('SECURITY', 'PIN Failed');
        }
      }
    } catch (e) {
       // Persisted Lockout Handling could be here
       if (mounted) {
          setState(() {
             _isAuthenticating = false;
             _statusMessage = 'Erreur: $e';
          });
          _shakeController.forward();
       }
    }
  }

  void _unlock() {
    ref.read(auditServiceProvider).log('SECURITY', 'Unlocked');
    widget.onUnlock();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Minimal AppBar for Logout
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: _showLogoutDialog,
            tooltip: 'Se déconnecter',
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: theme.colorScheme.surface.withOpacity(0.5),
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(
                       color: theme.colorScheme.primary.withOpacity(0.2),
                       blurRadius: 30,
                       spreadRadius: 5,
                     )
                   ]
                 ),
                 child: Icon(Icons.shield_rounded, size: 60, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Entrez votre code',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Status / Error
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * (0.5 - (0.5 * _shakeController.value)), 0), // Simple shake
                    child: Text(
                      _statusMessage ?? 'Sécurisez votre accès',
                      style: TextStyle(
                        color: _statusMessage != null ? theme.colorScheme.error : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _inputPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: filled ? theme.colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: filled ? theme.colorScheme.primary : Colors.grey.shade700,
                        width: 2,
                      ),
                      boxShadow: filled ? [
                         BoxShadow(color: theme.colorScheme.primary.withOpacity(0.5), blurRadius: 8)
                      ] : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),

              // Custom Keypad
              if (_showPinPad) ...[
                SizedBox(
                  width: 320,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        // Biometric Button (Bottom Left)
                        return _buildIconButton(Icons.fingerprint, () => _authenticateBiometrics());
                      }
                      if (index == 11) {
                        // Backspace (Bottom Right)
                        return _buildIconButton(Icons.backspace_outlined, _onBackspace);
                      }
                      if (index == 10) {
                        // 0 Button
                        return _buildNumButton('0');
                      }
                      // 1-9 Buttons
                      return _buildNumButton('${index + 1}');
                    },
                  ),
                ),
                if (_isMobile)
                  Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: TextButton(
                        onPressed: () => setState(() => _showPinPad = false),
                        child: const Text('Masquer le clavier'),
                      ),
                  ),
              ] else ...[
                 // Is Mobile and Hidden
                 ElevatedButton.icon(
                   onPressed: _authenticateBiometrics, 
                   icon: const Icon(Icons.fingerprint), 
                   label: const Text('Déverrouiller'),
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                   ),
                 ),
                 const SizedBox(height: 16),
                 TextButton(
                   onPressed: () => setState(() => _showPinPad = true),
                   child: const Text('Utiliser le Code PIN'),
                 ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Keypad Widgets
  Widget _buildNumButton(String text) {
     return Material(
       color: Colors.transparent,
       child: InkWell(
         borderRadius: BorderRadius.circular(40),
         onTap: () => _onKeyTap(text),
         splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
         child: Container(
           alignment: Alignment.center,
           decoration: BoxDecoration(
             shape: BoxShape.circle,
             color: Theme.of(context).colorScheme.surface.withOpacity(0.5), // Glassy Look
             border: Border.all(color: Colors.white.withOpacity(0.05)),
           ),
           child: Text(
             text,
             style: GoogleFonts.outfit(
               fontSize: 28,
               fontWeight: FontWeight.bold,
               color: Colors.white,
             ),
           ),
         ),
       ),
     );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
     return Material(
       color: Colors.transparent,
       child: InkWell(
         borderRadius: BorderRadius.circular(40),
         onTap: onTap,
         child: Container(
           alignment: Alignment.center,
           child: Icon(icon, color: Colors.white70, size: 28),
         ),
       ),
     );
  }

  void _showLogoutDialog() {
      // KEEPING OLD LOGIC FOR SAFETY, JUST REDESIGN DIALOG?
      // For brevity, reusing standard showDialog logic but maybe apply theme styles?
      // Theme handles dialog styles.
      showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: const Text('Déconnexion'),
         content: const Text('Voulez-vous quitter ?'),
         actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Annuler')),
            TextButton(
              onPressed: () async {
                 Navigator.pop(ctx);
                 await FirebaseAuth.instance.signOut();
                 await ref.read(pinServiceProvider).removePin();
                 ref.invalidate(pinHasPinProvider);
                 if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                 }
              }, 
              child: const Text('Confirmer', style: TextStyle(color: Colors.red))
            ),
         ],
       ),
      );
  }

  // FIXED RESET PIN DIALOG
  void _showResetPinDialog() {
    final passwordController = TextEditingController();
    
    // We use a separate State for the dialog to handle its loading status independent of parent
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Réinitialisation du PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Identifiez-vous pour supprimer le PIN actuel.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe Firebase',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                if (isLoading)
                  const SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                else ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                       // 1. Loading State
                       setState(() => isLoading = true);
                       
                       try {
                         final user = FirebaseAuth.instance.currentUser;
                         final pwd = passwordController.text.trim();
                         
                         if (user == null) throw 'Aucun utilisateur connecté.';
                         if (user.email == null) throw 'Email utilisateur masqué.';
                         if (pwd.isEmpty) throw 'Veuillez entrer le mot de passe.';

                         if (pwd.isEmpty) throw 'Veuillez entrer le mot de passe.';

                         // WORKAROUND: reauthenticateWithCredential crashes on Windows (Native threading issue)
                         // We use signInWithEmailAndPassword instead to verify the password.
                         // This effectively re-authenticates the user or signs them in again.
                         
                         // ignore: unused_local_variable
                         final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                           email: user.email!, 
                           password: pwd
                         );
                         
                         if (FirebaseAuth.instance.currentUser?.uid != user.uid) {
                           // Should technically not happen if email is same, but sanity check
                           throw 'Erreur de compte lors de la vérification.';
                         }

                         print('DEBUG: Password Verified (via SignIn)');

                         // 3. Remove PIN Logic
                         
                         // 3. Remove PIN Logic
                         await ref.read(pinServiceProvider).removePin();
                         
                         if (!context.mounted) return;
                         
                         Navigator.pop(context); // Close Password Dialog logic

                         // 4. Success Alert
                         showDialog(
                           context: context,
                           barrierDismissible: false,
                           builder: (successCtx) => AlertDialog(
                             title: const Text('Succès'),
                             content: const Text('PIN réinitialisé avec succès.\nVous allez être redirigé vers la configuration du PIN.'),
                             actions: [
                               TextButton(
                                 onPressed: () {
                                   Navigator.pop(successCtx); // Close Success Alert
                                   
                                   // Invalidate provider to update AuthGate
                                   ref.invalidate(pinHasPinProvider);
                                   
                                   // Explicit Redirect (as requested)
                                   Navigator.pushReplacement(
                                     context,
                                     MaterialPageRoute(builder: (_) => const CreatePinScreen())
                                   );
                                 },
                                 child: const Text('OK'),
                               ),
                             ],
                           ),
                         );

                         ref.read(auditServiceProvider).log('SECURITY', 'PIN reset via Password');

                       } on FirebaseAuthException catch (e) {
                         if (context.mounted) {
                           String msg = e.message ?? 'Erreur inconnue';
                           if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                             msg = 'Mot de passe incorrect.';
                           }
                           
                           showDialog(
                             context: context,
                             builder: (errCtx) => AlertDialog(
                               title: const Text('Erreur'),
                               content: Text(msg, style: const TextStyle(color: Colors.red)),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.pop(errCtx),
                                   child: const Text('OK'),
                                 )
                               ],
                             ),
                           );
                         }
                       } catch (e) {
                         if (context.mounted) {
                           showDialog(
                             context: context,
                             builder: (errCtx) => AlertDialog(
                               title: const Text('Erreur'),
                               content: Text(e.toString()),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.pop(errCtx),
                                   child: const Text('OK'),
                                 )
                               ],
                             ),
                           );
                         }
                       } finally {
                         if (context.mounted) {
                           setState(() => isLoading = false);
                         }
                       }
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ]
              ],
            );
          },
        );
      },
    );
  }
}
