import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart'; // Reuse our new button if desired, or simpler logic

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onActionPressed;

  const EmptyStateWidget({
     super.key, 
     required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security_update_good,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "C'est un peu vide ici...",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Ajoutez votre premier compte 2FA pour sécuriser vos accès.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scanner un code'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
