import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/finance_model.dart';
import '../models/activity_model.dart';

class PdfExportHelper {
  /// Exports Finance transactions to a PDF document and opens the print/save dialog
  static Future<void> exportFinances(
      List<FinanceTransactionModel> transactions, String title) async {
    final pdf = pw.Document();

    final headers = [
      'Date & Heure',
      'Référence',
      'Type',
      'Description',
      'Mode',
      'Employé',
      'Montant'
    ];

    final data = transactions.map((t) {
      final dateStr = DateFormat('dd/MM/yy HH:mm').format(t.dateTime);
      final isIncomeStr = t.isIncome ? '+' : '-';
      final typeStr = t.isIncome ? 'Entrée' : 'Sortie';
      return [
        dateStr,
        t.reference.isEmpty ? '-' : t.reference,
        typeStr,
        t.description,
        t.paymentMethodLabel,
        t.employeeName,
        '$isIncomeStr${t.amount.toStringAsFixed(0)} FCFA',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(title),
            pw.SizedBox(height: 20),
            _buildTable(headers, data),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'export_finances.pdf');
  }

  /// Exports Activity logs to a PDF document and opens the print/save dialog
  static Future<void> exportActivities(
      List<ActivityModel> activities, String title) async {
    final pdf = pw.Document();

    final headers = [
      'Date & Heure',
      'Action',
      'Utilisateur',
      'Réf.',
      'Détails',
      'Statut'
    ];

    final data = activities.map((a) {
      final dateStr = DateFormat('dd/MM/yy HH:mm').format(a.dateTime);
      return [
        dateStr,
        a.typeLabel,
        a.employeeName.isEmpty ? 'Système' : a.employeeName,
        a.reference.isEmpty ? '-' : a.reference,
        a.notes,
        a.statusLabel,
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(title),
            pw.SizedBox(height: 20),
            _buildTable(headers, data),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'export_activites.pdf');
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'BigPharma - Rapport',
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800),
            ),
            pw.Text(
              title,
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.normal,
                  color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Text(
          'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(List<String> headers, List<List<String>> data) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.teal600,
      ),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.centerRight,
      },
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColors.grey50,
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 5),
        pw.Text(
          'Généré automatiquement par le système BigPharma',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// Prints a single activity receipt
  static Future<void> printSingleActivity(ActivityModel activity) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'REÇU D\'ACTIVITÉ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(activity.dateTime)}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Opérateur: ${activity.employeeName}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Réf: ${activity.reference}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Type: ${activity.typeLabel}', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),
              pw.Text('DÉTAILS:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text(activity.notes, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MONTANT TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('${activity.totalAmount.toStringAsFixed(0)} FCFA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ]
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('*** BIGPHARMA ***', style: const pw.TextStyle(fontSize: 10)),
              )
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

}