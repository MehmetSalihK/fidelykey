import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/totp/domain/entities/totp_account.dart';

class PdfService {
  Future<void> generateRecoveryKit(List<TotpAccount> accounts) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 32),
            _buildWarning(),
            pw.SizedBox(height: 32),
            _buildAccountsTable(accounts),
            pw.SizedBox(height: 48),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'FidelyKey_Recovery_Kit.pdf',
    );
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FidelyKey',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Kit de Récupération - CONFIDENTIEL',
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _buildWarning() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        border: pw.Border.all(color: PdfColors.red200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Text('⚠️ ', style: const pw.TextStyle(fontSize: 20)),
          pw.Expanded(
            child: pw.Text(
              'Gardez ce document en lieu sûr (ex: Coffre-fort). Il contient les clés secrètes permettant de restaurer l\'accès à vos comptes. Ne le partagez jamais.',
              style: pw.TextStyle(color: PdfColors.red900),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAccountsTable(List<TotpAccount> accounts) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Compte', isHeader: true),
            _buildTableCell('Clé Secrète (Base 32)', isHeader: true),
            _buildTableCell('Algorithme', isHeader: true),
          ],
        ),
        // Rows
        ...accounts.map((account) {
          return pw.TableRow(
            children: [
              _buildTableCell('${account.issuer ?? ""}\n${account.accountName}'),
              _buildTableCell(account.secretKey, isMono: true),
              _buildTableCell('${account.algorithm}\n${account.digits} digits'),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isMono = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: isMono ? pw.Font.courier() : null, // Uses standard courier for mono
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Généré par FidelyKey',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              DateTime.now().toString().split('.')[0],
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
