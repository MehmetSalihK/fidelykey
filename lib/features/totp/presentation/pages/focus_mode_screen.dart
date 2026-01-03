import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../domain/entities/totp_account.dart';
import '../providers/totp_providers.dart';
import '../widgets/service_icon.dart';

class FocusModeScreen extends ConsumerWidget {
  final TotpAccount account;

  const FocusModeScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(totpCodeProvider(account));
    final progress = ref.watch(totpProgressProvider);
    final remaining = ref.watch(totpTimerProvider);

    // Format code with space
    final formattedCode = code.length == 6 
        ? '${code.substring(0, 3)} ${code.substring(3)}' 
        : code;

    // Remaining color logic
    Color timerColor = Colors.green;
    remaining.whenData((val) {
       if (val < 10) timerColor = Colors.red;
       else if (val < 20) timerColor = Colors.orange;
    });
    
    // Value for percent indicator
    double percent = 1.0;
    progress.whenData((val) => percent = val);

    return Scaffold(
      backgroundColor: Colors.black, // Immersive dark mode
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // HERO ICON
            Hero(
              tag: 'icon_${account.id}',
              child: ServiceIcon(
                issuer: account.issuer ?? '',
                accountName: account.accountName,
                size: 80,
              ),
            ),
            const SizedBox(height: 32),
            
            // Account Name
            Text(
              account.issuer ?? 'Service Inconnu',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 24,
              ),
            ),
            Text(
              account.accountName,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 64),

            // HERO CODE + Circular Timer
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 140.0,
                  lineWidth: 8.0,
                  percent: percent,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Colors.white10,
                  progressColor: timerColor,
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 100, // Smooth transition
                ),
                Hero(
                  tag: 'code_${account.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      formattedCode,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 64),

            // COPY BUTTON
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié ! (Mode Focus)')),
                  );
                  Navigator.pop(context); // Optional: close on copy? No, let user view.
                },
                icon: const Icon(Icons.copy),
                label: const Text('COPIER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
