import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/pin_service.dart';
import '../providers/auth_provider.dart';
import '../../../totp/presentation/pages/dashboard_screen.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  String _pin = '';
  String _confirmedPin = '';
  bool _isConfirming = false;
  String _errorText = '';

  void _onKeyPress(String value) {
    setState(() {
      _errorText = '';
      if (_pin.length < 4) {
        _pin += value;
        if (_pin.length == 4) {
          _handlePinComplete();
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      _errorText = '';
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  void _handlePinComplete() {
    if (_isConfirming) {
      if (_pin == _confirmedPin) {
        _savePin();
      } else {
        setState(() {
          _errorText = 'Les codes PIN ne correspondent pas. Réessayez.';
          _pin = '';
          _confirmedPin = '';
          _isConfirming = false;
        });
      }
    } else {
      setState(() {
        _confirmedPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
    }
  }

  Future<void> _savePin() async {
    await ref.read(pinServiceProvider).savePin(_pin);
    // Invalidate the provider so AuthGate knows we have a PIN now
    ref.invalidate(pinHasPinProvider);
    
    if (mounted) {
       Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _isConfirming ? 'Confirmez le code PIN' : 'Créer un code PIN',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isConfirming 
                              ? 'Entrez le code une seconde fois pour valider' 
                              : 'Sécurisez l\'accès à vos comptes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // PIN Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final isFilled = index < _pin.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled 
                                    ? colorScheme.primary 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isFilled ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.2),
                                  width: 2
                                ),
                              ),
                            );
                          }),
                        ),
                        
                        if (_errorText.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                               color: colorScheme.error.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorText,
                              style: GoogleFonts.outfit(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        const Spacer(),
                        const SizedBox(height: 32),
                        
                        // Numpad
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            children: [
                              for (var row = 0; row < 3; row++) 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(3, (col) {
                                      final number = (row * 3 + col + 1).toString();
                                      return _NumberButton(
                                        number: number,
                                        onTap: () => _onKeyPress(number),
                                      );
                                    }),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(width: 72), // Empty space
                                  _NumberButton(
                                    number: '0',
                                    onTap: () => _onKeyPress('0'),
                                  ),
                                  _DeleteButton(onTap: _onDelete),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;

  const _NumberButton({required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.05), // Subtle background
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            number,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w500,
               color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
