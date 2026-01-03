import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/services/secure_storage_service.dart';
import '../../../totp/presentation/providers/totp_providers.dart';
import 'audit_log_screen.dart';
import '../../../../core/services/pin_service.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/pdf_service.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricsEnabled = true;
  String? _pinHash;
  String? _duressPinHash;
  
  final String _bioKey = 'biometrics_enabled';
  final String _pinKey = 'user_pin_hash';
  final String _duressKey = 'duress_pin_hash';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageServiceProvider);
    final bioVal = await storage.getString(_bioKey);
    final pinVal = await storage.getString(_pinKey);
    final duressVal = await storage.getString(_duressKey);
    
    setState(() {
      _biometricsEnabled = bioVal != 'false';
      _pinHash = pinVal;
      _duressPinHash = duressVal;
    });
  }

  Future<void> _setPin(String key, String title) async {
    final pin = await showDialog<String>(
      context: context,
      builder: (c) => _PinDialog(title: title),
    );

    if (pin != null && pin.length == 4) {
      final bytes = utf8.encode(pin);
      final hash = sha256.convert(bytes).toString();
      
      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveString(key, hash);
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code PIN enregistré avec succès.')));
      }
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveString(_bioKey, value.toString());
    setState(() {
    });
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Sign Out
      await FirebaseAuth.instance.signOut();
      
      // 2. Clear Local PIN
      await ref.read(pinServiceProvider).removePin();
      
      // 3. Clear State
      ref.invalidate(accountsProvider);

      if (!mounted) return;
      
      // 4. Redirect
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Appareance (Mock - Needs App State lifted up)
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Thème'),
            subtitle: const Text('Utilise le thème du système par défaut'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pour l\'instant, le thème suit le système.')));
            },
          ),
          const Divider(),
          
          // Security
          Padding(
             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
             child: Text('Sécurité', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Authentification Biom.'),
            subtitle: const Text('Requis au démarrage'),
            value: _biometricsEnabled,
            onChanged: _toggleBiometrics,
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Code PIN de Connexion'),
            subtitle: Text(_pinHash != null ? 'Configuré' : 'Non configuré'),
            trailing: const Icon(Icons.edit, size: 16),
            onTap: () => _setPin(_pinKey, 'Définir PIN Connexion'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_person, color: Colors.orange),
            title: const Text('Code de Contrainte (Duress)'),
            subtitle: Text(_duressPinHash != null ? 'Configuré' : 'Non configuré'),
            trailing: const Icon(Icons.edit, size: 16),
            onTap: () => _setPin(_duressKey, 'Définir PIN Contrainte'),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blueGrey),
            title: const Text('Journal de Sécurité'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (c) => const AuditLogScreen()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.print, color: Colors.blueAccent),
            title: const Text('Kit de Récupération (PDF)'),
            subtitle: const Text('Imprimer vos codes de secours'),
            onTap: () async {
               // Security Check
               if (_pinHash != null) {
                 final pin = await showDialog<String>(context: context, builder: (c) => const _PinDialog(title: 'Confirmer PIN'));
                 if (pin == null) return;
                 
                 final bytes = utf8.encode(pin);
                 final hash = sha256.convert(bytes).toString();
                 if (hash != _pinHash) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN Incorrect')));
                   return;
                 }
               }
               
               final accounts = await ref.read(accountsProvider.future);
               await PdfService().generateRecoveryKit(accounts);
            },
          ),
          const Divider(),

          // About
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('FidelyKey'),
            subtitle: Text('Version 1.0.0'),
          ),
          const SizedBox(height: 32),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Se déconnecter', 
              style: TextStyle(
                color: Theme.of(context).colorScheme.error, 
                fontWeight: FontWeight.bold
              )
            ),
            onTap: _confirmLogout,
          ),
          const SizedBox(height: 16),

          // Danger Zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Zone de Danger',
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Supprimer toutes les données', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('TOUT SUPPRIMER ?'),
                  content: const Text(
                    'Attention, cette action effacera tous vos comptes 2FA.\nVous perdrez l\'accès à vos services si vous n\'avez pas de sauvegarde.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(c, true), 
                      child: const Text('CONFIRMER SUPPRESSION')
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                 final storage = ref.read(secureStorageServiceProvider);
                 await storage.clearAll();
                 ref.invalidate(accountsProvider); // Will reload empty list
                 
                 if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Données effacées.')));
                 }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  final String title;
  const _PinDialog({required this.title});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        maxLength: 4,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: '4 chiffres',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () {
            if (_controller.text.length == 4) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
