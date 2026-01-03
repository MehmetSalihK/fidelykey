import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/audit_service.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  List<AuditLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final service = ref.read(auditServiceProvider);
    final logs = await service.getLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'AUTH': return Icons.verified_user;
      case 'SECURITY': return Icons.security;
      case 'ACCOUNT': return Icons.manage_accounts;
      case 'DATA': return Icons.save;
      default: return Icons.info;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'AUTH': return Colors.green;
      case 'SECURITY': return Colors.red;
      case 'ACCOUNT': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de sécurité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
               await ref.read(auditServiceProvider).clearLogs();
               _loadLogs();
            },
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty 
              ? Center(child: Text('Aucun évènement.', style: GoogleFonts.poppins()))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColor(log.type).withOpacity(0.1),
                        child: Icon(_getIcon(log.type), color: _getColor(log.type), size: 18),
                      ),
                      title: Text(log.description, style: GoogleFonts.poppins(fontSize: 14)),
                      subtitle: Text(
                        DateFormat('dd/MM HH:mm:ss').format(log.timestamp),
                         style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
    );
  }
}
