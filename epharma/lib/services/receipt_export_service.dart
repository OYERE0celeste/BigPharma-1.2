import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../widgets/receipt_ticket.dart';

class ReceiptExportService {
  ReceiptExportService._();

  static Future<void> downloadReceipt(
    ReceiptTicketData data, {
    String? filename,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (context) => _buildTicket(data),
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: filename ?? '${data.invoiceNumber}.pdf',
    );
  }

  static Future<void> downloadPdfBytes(
    Uint8List bytes, {
    required String filename,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static pw.Widget _buildTicket(ReceiptTicketData data) {
    final baseStyle = pw.TextStyle(font: pw.Font.courier(), fontSize: 10);
    final boldStyle = pw.TextStyle(
      font: pw.Font.courierBold(),
      fontSize: 10,
    );

    pw.Widget center(String text, {pw.TextStyle? style}) {
      return pw.SizedBox(
        width: double.infinity,
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: style ?? baseStyle,
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        center(data.pharmacyName, style: boldStyle),
        center('TEL : ${data.pharmacyPhone}', style: baseStyle),
        center(data.pharmacistName, style: baseStyle),
        pw.SizedBox(height: 8),
        pw.Text(
          'OP: ${data.operatorName.toUpperCase()} le ${ReceiptTicketFormatters.operationDate(data.operationDate)}',
          style: baseStyle,
        ),
        pw.Text('${data.documentLabel}  ${data.caisseLabel}', style: baseStyle),
        pw.SizedBox(height: 4),
        pw.Text('------------------------------------', style: baseStyle),
        pw.Text(
          'Facture N ${data.invoiceNumber} du ${ReceiptTicketFormatters.fullDate(data.invoiceDate)}',
          style: boldStyle,
        ),
        pw.SizedBox(height: 8),
        pw.Text('Design.    Prix  Qte %rem. Montant', style: boldStyle),
        pw.SizedBox(height: 6),
        ...data.items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.designation.toUpperCase(), style: boldStyle),
                pw.Text(
                  '           ${ReceiptTicketFormatters.money(item.unitPrice)} x ${ReceiptTicketFormatters.quantity(item.quantity)}       ${ReceiptTicketFormatters.money(item.total)}',
                  style: baseStyle,
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Total:     ${ReceiptTicketFormatters.money(data.totalAmount)} Assur :    ${ReceiptTicketFormatters.money(data.coveredAmount)} F',
          style: boldStyle,
        ),
        pw.Text('------------------------------------', style: baseStyle),
        pw.Text(
          'Total ticket: ${ReceiptTicketFormatters.money(data.totalAmount)} FCFA (${ReceiptTicketFormatters.euros(data.totalAmount)} Euros)',
          style: boldStyle,
        ),
        pw.Text(
          'Encaiss :     ${ReceiptTicketFormatters.money(data.amountReceived).padLeft(8, ' ')} F',
          style: baseStyle,
        ),
        pw.Text(
          '${data.balanceLabel}:     ${ReceiptTicketFormatters.money(data.balanceAmount).padLeft(8, ' ')} F',
          style: baseStyle,
        ),
        pw.Text('===', style: baseStyle),
        pw.SizedBox(height: 4),
        center('|||||| |||||||||| |||||||| ||| |||||', style: baseStyle),
        center('*${data.barcodeValue}*', style: boldStyle),
        pw.SizedBox(height: 12),
        ...data.footerLines.map((line) => center(line, style: baseStyle)),
      ],
    );
  }
}
