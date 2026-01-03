import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'qr_login_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialEmail; // For QR Login
  const LoginScreen({super.key, this.initialEmail});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    // Hide keyboard
    FocusScope.of(context).unfocus();

    try {
      await ref.read(authServiceProvider).signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // AuthGate handles navigation
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        // Friendly Firebase Error Messages could be mapped here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg), 
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cyber-Clean Layout
    return Scaffold(
      // Background gradient or color handled by Theme, 
      // but we can add a subtle gradient mesh if needed in generic layout.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero Logo
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                           BoxShadow(
                             color: AppTheme.primaryIndigo.withOpacity(0.5),
                             blurRadius: 40,
                             spreadRadius: 2,
                           )
                        ],
                      ),
                      child: const Icon(Icons.shield_rounded, size: 50, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 2. Titles
                  Text(
                    'Bon retour',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous à votre coffre-fort',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  // 3. Inputs
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.contains('@') ? null : 'Email invalide',
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? '6 caractères minimum' : null,
                  ),

                  // 4. Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordScreen()));
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: AppTheme.accentNeon.withOpacity(0.8)),
                      ),
                    ),
                  ),
                  
                  // QR Code Login Link (Desktop/Web mainly)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white70),
                      label: const Text('Connexion par QR Code (Mobile)', style: TextStyle(color: Colors.white70)),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (c) => const QrLoginScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Action
                  PrimaryButton(
                    text: 'SE CONNECTER',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 6. Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Pas de compte ? ', style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen()));
                        },
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
