import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../domain/entities/totp_account.dart';
import '../providers/totp_providers.dart';
import '../pages/focus_mode_screen.dart';
import 'edit_account_dialog.dart';
import 'service_icon.dart';
import '../../../../core/widgets/glass_card.dart';

class TotpAccountCard extends ConsumerWidget {
  final TotpAccount account;
  final bool isDesktop;

  const TotpAccountCard({
    Key? key,
    required this.account,
    this.isDesktop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(totpCodeProvider(account));
    final timerAsync = ref.watch(totpTimerProvider); 
    final remainingSeconds = timerAsync.value ?? 30;
    final progress = remainingSeconds / 30.0;

    return _CardInteractive(
      account: account, 
      code: code, 
      progress: progress,
      remainingSeconds: remainingSeconds,
      isDesktop: isDesktop,
    );
  }
}

class _CardInteractive extends ConsumerStatefulWidget {
  final TotpAccount account;
  final String code;
  final double progress;
  final int remainingSeconds;
  final bool isDesktop;

  const _CardInteractive({
    required this.account,
    required this.code,
    required this.progress,
    required this.remainingSeconds,
    required this.isDesktop,
  });

  @override
  ConsumerState<_CardInteractive> createState() => _CardInteractiveState();
}

class _CardInteractiveState extends ConsumerState<_CardInteractive> {
  bool _isHovered = false;
  bool _isObscured = true; // Privacy Default
  Timer? _revealTimer;

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _revealCode() {
    if (!_isObscured) return; // Already revealed
    
    setState(() => _isObscured = false);
    HapticFeedback.lightImpact();
    
    // Auto-hide after 5 seconds
    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isObscured = true);
    });
  }

  void _toggleFavorite() {
    // We assume 'isFavorite' is part of the account object.
    // Provider update logic needs to be robust (creating new object)
    final updatedAccount = widget.account.copyWith(isFavorite: !widget.account.isFavorite);
    ref.read(accountsProvider.notifier).saveAccount(updatedAccount);
    HapticFeedback.selectionClick();
  }

  void _copyToClipboard() {
    // Increment Usage
    ref.read(accountsProvider.notifier).incrementUsage(widget.account.id);
    
    Clipboard.setData(ClipboardData(text: widget.code.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié !'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    Color timerColor = Colors.green;
    if (widget.remainingSeconds < 10) timerColor = Colors.orange;
    if (widget.remainingSeconds < 5) timerColor = Colors.red;

    final theme = Theme.of(context);
    final isFav = widget.account.isFavorite;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _revealCode,
        onLongPress: _copyToClipboard,
        child: AnimatedScale(
          scale: _isHovered && widget.isDesktop ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: GlassCard(
            opacity: 0.8,
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Logo
                      GestureDetector(
                         onDoubleTap: () {
                           Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___)=>FocusModeScreen(account: widget.account)));
                         },
                         child: Hero(
                          tag: 'icon_${widget.account.id}',
                          child: ServiceIcon(
                            issuer: widget.account.issuer ?? '',
                            accountName: widget.account.accountName,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Info & Code
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Row(
                               children: [
                                  Expanded(
                                    child: Text(
                                      widget.account.issuer ?? 'Service Inconnu',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Star Icon
                                  GestureDetector(
                                    onTap: _toggleFavorite,
                                    child: Icon(
                                      isFav ? Icons.star : Icons.star_border,
                                      color: isFav ? Colors.amber : Colors.white24,
                                      size: 20,
                                    ),
                                  ),
                               ],
                             ),
                             const SizedBox(height: 4),
                             Text(
                               widget.account.accountName,
                               style: theme.textTheme.bodyMedium?.copyWith(
                                 color: Colors.white,
                               ),
                               overflow: TextOverflow.ellipsis,
                             ),
                             const SizedBox(height: 8),
                             
                             // CODE DISPLAY
                             _buildCodeWidget(theme),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Timer
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 4.0,
                        percent: widget.progress.clamp(0.0, 1.0),
                        progressColor: timerColor,
                        backgroundColor: Colors.white12,
                        center: Text(
                           "${widget.remainingSeconds}",
                           style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),

                      if (!widget.isDesktop) 
                        _buildMobileMenu(),
                    ],
                  ),
                ),
                
                // Desktop Edit Buttons
                if (widget.isDesktop && _isHovered)
                   Positioned(
                     bottom: 8, right: 8,
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                          IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: _copyToClipboard, tooltip: 'Copier'),
                          IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: _showEditDialog, tooltip: 'Modifier'),
                       ],
                     ),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeWidget(ThemeData theme) {
    if (_isObscured) {
       // OBSCURED STATE
       return Row(
         children: [
           Text(
             '••••••', 
             style: GoogleFonts.jetBrainsMono(
               fontSize: 24, 
               color: Colors.white24,
               letterSpacing: 4,
             )
           ),
           const SizedBox(width: 8),
           Icon(Icons.visibility_off, size: 16, color: Colors.white24),
         ],
       );
    }
    
    // REVEALED STATE
    return Text(
        _formatCode(widget.code),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary, // Cyber Neon Color
          letterSpacing: 2,
        ),
    );
  }

  Widget _buildMobileMenu() {
     return PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Colors.white54),
        onSelected: (value) {
          if (value == 'edit') {
             _showEditDialog();
          } else if (value == 'delete') {
             _confirmDelete();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Modifier')])),
          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
        ],
      );
  }

  void _showEditDialog() {
     showDialog(context: context, builder: (_) => EditAccountDialog(account: widget.account));
  }

  void _confirmDelete() {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Voulez-vous vraiment supprimer ${widget.account.issuer} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(accountsProvider.notifier).deleteAccount(widget.account.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }
}
