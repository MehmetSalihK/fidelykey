import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/totp_service.dart';
import '../providers/totp_providers.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _accountController = TextEditingController();
  final _secretController = TextEditingController();

  bool _isSecretVisible = false;
  
  // Default settings
  String _algorithm = 'SHA1';
  int _digits = 6;
  int _period = 30;

  @override
  void dispose() {
    _issuerController.dispose();
    _accountController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final secret = _secretController.text.trim();
      
      ref.read(accountsProvider.notifier).addAccount(
        secret: secret,
        name: _accountController.text.trim(),
        issuer: _issuerController.text.trim(),
        algorithm: _algorithm,
        digits: _digits,
        period: _period,
      ).then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saisie Manuelle')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            onChanged: () => setState((){}), // Rebuild to update button state
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                 Text(
                   'Ajouter un compte',
                   style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   'Entrez les détails fournis par votre service (Clé secrète).',
                   style: GoogleFonts.poppins(color: Colors.grey),
                 ),
                 const SizedBox(height: 32),

                 // Issuer
                 TextFormField(
                   controller: _issuerController,
                   decoration: const InputDecoration(
                     labelText: 'Service (ex: Google, Facebook)',
                     prefixIcon: Icon(Icons.business),
                     border: OutlineInputBorder(),
                   ),
                   validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                 ),
                 const SizedBox(height: 16),

                 // Account Name
                 TextFormField(
                   controller: _accountController,
                   decoration: const InputDecoration(
                     labelText: 'Nom du compte (ex: email)',
                     prefixIcon: Icon(Icons.person),
                     border: OutlineInputBorder(),
                   ),
                   validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                 ),
                 const SizedBox(height: 16),

                 // Secret Key
                 TextFormField(
                   controller: _secretController,
                   obscureText: !_isSecretVisible,
                   keyboardType: TextInputType.visiblePassword,
                   decoration: InputDecoration(
                     labelText: 'Clé Secrète (Base32)',
                     prefixIcon: const Icon(Icons.key),
                     border: const OutlineInputBorder(),
                     suffixIcon: IconButton(
                       icon: Icon(_isSecretVisible ? Icons.visibility_off : Icons.visibility),
                       onPressed: () => setState(() => _isSecretVisible = !_isSecretVisible),
                     ),
                   ),
                   validator: (value) {
                     if (value == null || value.isEmpty) return 'Requis';
                     // Validate Base32
                     if (!ref.read(totpServiceProvider).isValidSecret(value)) {
                       return 'Format Base32 invalide';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 24),
                 
                 // Advanced Options
                 ExpansionTile(
                   title: const Text('Options Avancées'),
                   children: [
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Column(
                         children: [
                           DropdownButtonFormField<String>(
                             value: _algorithm,
                             decoration: const InputDecoration(labelText: 'Algorithme'),
                             items: ['SHA1', 'SHA256', 'SHA512']
                                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                 .toList(),
                             onChanged: (v) => setState(() => _algorithm = v!),
                           ),
                           const SizedBox(height: 12),
                           Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                   initialValue: '6',
                                   keyboardType: TextInputType.number,
                                   decoration: const InputDecoration(labelText: 'Chiffres'),
                                   onChanged: (v) => _digits = int.tryParse(v) ?? 6,
                                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                 ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                   initialValue: '30',
                                   keyboardType: TextInputType.number,
                                   decoration: const InputDecoration(labelText: 'Période (sec)'),
                                   onChanged: (v) => _period = int.tryParse(v) ?? 30,
                                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                 ),
                              ),
                            ],
                           )
                         ],
                       ),
                     )
                   ],
                 ),

                 const SizedBox(height: 32),
                 
                 // Submit Button
                 SizedBox(
                   height: 50,
                   child: FilledButton.icon(
                     onPressed: _isFormValid() ? _save : null,
                     icon: const Icon(Icons.check),
                     label: const Text('AJOUTER LE COMPTE'),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
     // Simple pre-check for button state enablement visual feedback
     return _issuerController.text.isNotEmpty && 
            _accountController.text.isNotEmpty && 
            _secretController.text.isNotEmpty;
  }
}
