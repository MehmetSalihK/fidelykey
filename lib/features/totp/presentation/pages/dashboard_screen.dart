import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/totp_account.dart';
import '../providers/totp_providers.dart';
import '../widgets/totp_account_card.dart';
import 'qr_scanner_screen.dart';
import 'manual_entry_screen.dart';
import '../../../../features/settings/presentation/pages/settings_screen.dart';
import '../widgets/account_skeleton.dart';
import '../widgets/empty_state_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final bool isDesktop;

  const DashboardScreen({super.key, this.isDesktop = false});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  // Desktop specific focus
  final FocusNode _keyboardListenerFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isDesktop) {
      _isSearchActive = true; // Always show search field on desktop header? 
      // Or we can toggle it. Let's keep it toggleable or just open.
      // Plan said: "Ctrl + F : Focus sur la barre de recherche."
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _keyboardListenerFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).set('');
      }
    });
  }

  // SHORTCUTS HANDLER
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        // Ctrl + F -> Focus Search
        _toggleSearch(); // Open if closed
        setState(() => _isSearchActive = true);
         // set focus... needs a focus node on TextField
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyN) {
        // Ctrl + N -> Add Account
        _showAddOptions(context, ref);
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        // ESC -> Clear Search or Close
        if (_searchController.text.isNotEmpty) {
           _searchController.clear();
           ref.read(searchQueryProvider.notifier).set('');
        } else if (_isSearchActive) {
           setState(() => _isSearchActive = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = ref.watch(filteredAccountsProvider);
    final baseAsync = ref.watch(accountsProvider);

    // Desktop: No Scaffold, just Content
    // Mobile: Scaffold
    if (widget.isDesktop) {
      return RawKeyboardListener( // Simple keyboard listener for now (Task 78)
        focusNode: _keyboardListenerFocus,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Column(
          children: [
            _buildDesktopHeader(context),
            Expanded(
              child: _buildBody(context, baseAsync, filteredList, ref),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: _buildMobileAppBar(context),
        body: _buildBody(context, baseAsync, filteredList, ref),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOptions(context, ref),
          child: const Icon(Icons.add),
        ),
      );
    }
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            'Tableau de bord',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Search Bar
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher (Ctrl+F)',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onChanged: (val) => ref.read(searchQueryProvider.notifier).set(val),
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () => _showAddOptions(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau (Ctrl+N)'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: _isSearchActive
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.titleLarge?.color),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                 ref.read(searchQueryProvider.notifier).set(val);
              },
            )
          : Text(
              'FidelyKey',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
      actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearchActive)
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()));
              },
              icon: const Icon(Icons.settings),
            ),
          const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AsyncValue baseAsync, List<TotpAccount> filteredList, WidgetRef ref) {
    return baseAsync.when(
      data: (_) {
         if (filteredList.isEmpty) {
           if (_searchController.text.isNotEmpty) {
              return Center(child: Text('Aucun résultat trouvé.', style: GoogleFonts.poppins()));
           }
           if (_searchController.text.isEmpty) {
              return _buildEmptyState(context);
           }
         }
         
         return _buildResponsiveList(context, filteredList, ref);
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => const AccountSkeleton(),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Erreur: $err', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      onActionPressed: () => _showAddOptions(context, ref),
    );
  }

  Widget _buildResponsiveList(BuildContext context, List<TotpAccount> accounts, WidgetRef ref) {
    // If widget.isDesktop is FORCE true (from MainScreen), use Grid.
    // Else check mobile constraints.
    
    if (widget.isDesktop) {
       return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          childAspectRatio: 1.8,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return TotpAccountCard(account: accounts[index], isDesktop: true);
        },
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: accounts.length,
        cacheExtent: 500, // Optimize scrolling
        addAutomaticKeepAlives: false, // Don't keep non-visible items alive
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TotpAccountCard(account: accounts[index], isDesktop: false),
          );
        },
     );
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scanner un QR Code'),
              onTap: () {
                Navigator.pop(c);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.keyboard),
              title: const Text('Saisie Manuelle'),
              onTap: () {
                Navigator.pop(c);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualEntryScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
