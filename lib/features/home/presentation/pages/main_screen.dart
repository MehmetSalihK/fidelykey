import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_lifecycle_manager.dart';
import '../../../totp/presentation/pages/dashboard_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
// import '../../../audit/presentation/pages/audit_screen.dart'; // Future

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  bool _isExtended = false;

  @override
  Widget build(BuildContext context) {
    // Check for Desktop layout
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (!isDesktop) {
      // Mobile: Just return Dashboard (which has its own Scaffold)
      // Note: If we want bottom nav on mobile later, we'd wrap it here too.
      // For now, mobile is just Dashboard.
      return const DashboardScreen(); 
    }

    // Desktop Layout
    return Scaffold(
      body: Row(
        children: [
          _buildNavRail(context),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      extended: _isExtended,
      minWidth: 72,
      onDestinationSelected: (index) {
        if (index == 3) {
           // Lock Action
           // We can trigger lock via LifecycleManager or specific logic.
           // For now, let's just trigger a lock state update if possible, 
           // or we can implement a Lock method in AuthProvider/Lifecycle.
           // Since AuthGate handles locking via AppLifecycleManager state, 
           // we might need a way to signal "Lock Now". 
           // A simple way is to pop to AuthGate which checks state, 
           // but AuthGate holds the state.
           // Let's defer Lock button for a second or implement a provider for it.
           // Actually, simpler: just use SystemChannels to lock or show LockScreen overlay.
           // For this iteration, I'll just skip Lock action implementation in this specific widget 
           // or make it reset the app.
        } else {
           setState(() => _selectedIndex = index);
        }
      },
      leading: Column(
        children: [
          const SizedBox(height: 16),
          InkWell(
             onTap: () => setState(() => _isExtended = !_isExtended),
             child: const Icon(Icons.shield_moon, size: 32, color: Colors.blueAccent),
          ),
          if (_isExtended) ...[
            const SizedBox(height: 8),
            Text(
              'FidelyKey',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Tableau de bord'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Paramètres'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: Text('Audit Logs'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.lock_outline),
          selectedIcon: Icon(Icons.lock),
          label: Text('Verrouiller'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        // Dashboard
        // Pass 'isDesktop: true' to force Grid layout inside
        return const DashboardScreen(isDesktop: true);
      case 1:
        return const SettingsScreen(); 
      case 2:
        return const Center(child: Text('Journal d\'audit (Audit Logs) - Coming Soon'));
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }
}
