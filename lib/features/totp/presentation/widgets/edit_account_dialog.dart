import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/totp_account.dart';
import '../providers/totp_providers.dart';

class EditAccountDialog extends ConsumerStatefulWidget {
  final TotpAccount account;

  const EditAccountDialog({super.key, required this.account});

  @override
  ConsumerState<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends ConsumerState<EditAccountDialog> {
  late TextEditingController _issuerController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _issuerController = TextEditingController(text: widget.account.issuer);
    _nameController = TextEditingController(text: widget.account.accountName);
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(accountsProvider.notifier).updateAccount(
      id: widget.account.id,
      newName: _nameController.text.trim(),
      newIssuer: _issuerController.text.trim(),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le compte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _issuerController,
            decoration: const InputDecoration(labelText: 'Service (Issuer)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du compte'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Note : La clé secrète ne peut pas être modifiée pour des raisons de sécurité. Supprimez et recréez le compte si nécessaire.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}
