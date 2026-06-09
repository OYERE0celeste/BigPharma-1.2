import 'package:flutter/material.dart';

import '../models/order_invoice_model.dart';
import '../models/order_model.dart';
import '../models/sale_model.dart';
import 'bp_theme.dart';

class ReceiptTicketItemData {
  final String designation;
  final double unitPrice;
  final int quantity;
  final double discountPercent;
  final double total;

  const ReceiptTicketItemData({
    required this.designation,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    this.discountPercent = 0,
  });
}

class ReceiptTicketData {
  final String pharmacyName;
  final String pharmacyPhone;
  final String pharmacistName;
  final String operatorName;
  final DateTime operationDate;
  final String documentLabel;
  final String caisseLabel;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final List<ReceiptTicketItemData> items;
  final double totalAmount;
  final double coveredAmount;
  final double amountReceived;
  final String balanceLabel;
  final double balanceAmount;
  final String barcodeValue;
  final List<String> footerLines;

  const ReceiptTicketData({
    required this.pharmacyName,
    required this.pharmacyPhone,
    required this.pharmacistName,
    required this.operatorName,
    required this.operationDate,
    required this.documentLabel,
    required this.caisseLabel,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.items,
    required this.totalAmount,
    required this.coveredAmount,
    required this.amountReceived,
    required this.balanceLabel,
    required this.balanceAmount,
    required this.barcodeValue,
    this.footerLines = const [
      'MERCI ET PROMPTE GUERISON',
      'Les produits achetes ne sont ni repris ni',
      'echanges',
    ],
  });
}

class ReceiptTicketFactory {
  ReceiptTicketFactory._();

  static const String _defaultPharmacyName = 'PHARMACIE LA FLORALE';
  static const String _defaultPharmacyPhone = '06 857 57 84';
  static const String _defaultPharmacist = 'Dr Flora ONDELE';
  static const String _defaultOperator = 'NELLE';

  static ReceiptTicketData fromSale(Sale sale) {
    final balance = sale.amountReceived >= sale.totalAmount
        ? sale.amountReceived - sale.totalAmount
        : sale.totalAmount - sale.amountReceived;

    return ReceiptTicketData(
      pharmacyName: _defaultPharmacyName,
      pharmacyPhone: _defaultPharmacyPhone,
      pharmacistName: _defaultPharmacist,
      operatorName: _fallbackText(sale.pharmacist, _defaultOperator),
      operationDate: sale.dateTime,
      documentLabel: 'Bon de livraison',
      caisseLabel: 'Caisse 1',
      invoiceNumber: sale.invoiceNumber,
      invoiceDate: sale.dateTime,
      items: sale.items
          .map(
            (item) => ReceiptTicketItemData(
              designation: _fallbackText(item.productName, 'Produit'),
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              total: item.total,
            ),
          )
          .toList(),
      totalAmount: sale.totalAmount,
      coveredAmount: sale.totalAmount,
      amountReceived: sale.amountReceived,
      balanceLabel: sale.amountReceived >= sale.totalAmount
          ? 'A rendre'
          : 'A recevoir',
      balanceAmount: balance,
      barcodeValue: sale.invoiceNumber,
    );
  }

  static ReceiptTicketData fromOrder(
    OrderModel order, {
    String pharmacyName = _defaultPharmacyName,
    String pharmacyPhone = _defaultPharmacyPhone,
    String pharmacistName = _defaultPharmacist,
  }) {
    return ReceiptTicketData(
      pharmacyName: pharmacyName,
      pharmacyPhone: pharmacyPhone,
      pharmacistName: pharmacistName,
      operatorName: _fallbackText(order.userName, _defaultOperator),
      operationDate: order.createdAt,
      documentLabel: 'Bon de livraison',
      caisseLabel: 'Caisse 1',
      invoiceNumber: _fallbackText(order.invoiceNumber, order.orderNumber),
      invoiceDate: order.createdAt,
      items: order.items
          .map(
            (item) => ReceiptTicketItemData(
              designation: item.name,
              unitPrice: item.price,
              quantity: item.quantity,
              total: item.subtotal,
            ),
          )
          .toList(),
      totalAmount: order.totalPrice,
      coveredAmount: order.totalPrice,
      amountReceived: 0,
      balanceLabel: 'A recevoir',
      balanceAmount: order.totalPrice,
      barcodeValue: _fallbackText(order.invoiceNumber, order.orderNumber),
    );
  }

  static ReceiptTicketData fromOrderInvoice(
    OrderInvoiceModel invoice, {
    String? operatorName,
    String pharmacistName = _defaultPharmacist,
  }) {
    return ReceiptTicketData(
      pharmacyName: _fallbackText(invoice.pharmacyName, _defaultPharmacyName),
      pharmacyPhone: _fallbackText(
        invoice.pharmacyPhone,
        _defaultPharmacyPhone,
      ),
      pharmacistName: pharmacistName,
      operatorName: _fallbackText(operatorName, _defaultOperator),
      operationDate: invoice.invoiceDate,
      documentLabel: 'Bon de livraison',
      caisseLabel: 'Caisse 1',
      invoiceNumber: invoice.invoiceNumber,
      invoiceDate: invoice.invoiceDate,
      items: invoice.items
          .map(
            (item) => ReceiptTicketItemData(
              designation: item.name,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              total: item.total,
            ),
          )
          .toList(),
      totalAmount: invoice.totalAmount,
      coveredAmount: invoice.totalAmount,
      amountReceived: 0,
      balanceLabel: 'A recevoir',
      balanceAmount: invoice.totalAmount,
      barcodeValue: invoice.invoiceNumber,
    );
  }

  static String _fallbackText(String? value, String fallback) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? fallback : trimmed;
  }
}

class ReceiptTicketFormatters {
  ReceiptTicketFormatters._();

  static const double euroRate = 655.957;
  static const List<String> _months = [
    'janv',
    'fevr',
    'mars',
    'avr',
    'mai',
    'juin',
    'juil',
    'aout',
    'sept',
    'oct',
    'nov',
    'dec',
  ];

  static String money(double amount) => amount.toStringAsFixed(0);

  static String quantity(int quantity) => quantity.toString().padLeft(2, '0');

  static String operationDate(DateTime date) {
    final month = _months[date.month - 1];
    final year = (date.year % 100).toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day.toString().padLeft(2, '0')} $month $year  $hour:$minute';
  }

  static String fullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String euros(double amount) {
    return (amount / euroRate).toStringAsFixed(2);
  }
}

class ReceiptTicket extends StatelessWidget {
  const ReceiptTicket({super.key, required this.data});

  final ReceiptTicketData data;

  static const TextStyle _textStyle = TextStyle(
    fontFamily: 'Courier',
    fontSize: 12,
    color: BpColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle _boldStyle = TextStyle(
    fontFamily: 'Courier',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: BpColors.textPrimary,
    height: 1.35,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BpColors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BpColors.border),
        boxShadow: [
          BoxShadow(
            color: BpColors.primaryDark.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: _textStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _centerText(data.pharmacyName, style: _boldStyle),
            _centerText('TEL : ${data.pharmacyPhone}'),
            _centerText(data.pharmacistName),
            const SizedBox(height: 8),
            Text(
              'OP: ${data.operatorName.toUpperCase()} le ${ReceiptTicketFormatters.operationDate(data.operationDate)}',
            ),
            Text('${data.documentLabel}  ${data.caisseLabel}'),
            const SizedBox(height: 4),
            const Text('------------------------------------'),
            Text(
              'Facture N ${data.invoiceNumber} du ${ReceiptTicketFormatters.fullDate(data.invoiceDate)}',
              style: _boldStyle,
            ),
            const SizedBox(height: 8),
            const Text('Design.    Prix  Qte %rem. Montant', style: _boldStyle),
            const SizedBox(height: 6),
            ...data.items.map(_buildItem),
            const SizedBox(height: 8),
            _buildSummaryLine(
              'Total:',
              data.totalAmount,
              'Assur :',
              data.coveredAmount,
            ),
            const Text('------------------------------------'),
            Text(
              'Total ticket: ${ReceiptTicketFormatters.money(data.totalAmount)} FCFA (${ReceiptTicketFormatters.euros(data.totalAmount)} Euros)',
              style: _boldStyle,
            ),
            _buildMoneyLine('Encaiss :', data.amountReceived),
            _buildMoneyLine('${data.balanceLabel}:', data.balanceAmount),
            const Text('==='),
            const SizedBox(height: 4),
            _centerText('|||||| |||||||||| |||||||| ||| |||||'),
            _centerText('*${data.barcodeValue}*', style: _boldStyle),
            const SizedBox(height: 14),
            ...data.footerLines.map((line) => _centerText(line)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ReceiptTicketItemData item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.designation.toUpperCase(), style: _boldStyle),
          Text(
            '           ${ReceiptTicketFormatters.money(item.unitPrice)} x ${ReceiptTicketFormatters.quantity(item.quantity)}       ${ReceiptTicketFormatters.money(item.total)}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(
    String leftLabel,
    double leftValue,
    String rightLabel,
    double rightValue,
  ) {
    return Text(
      '$leftLabel     ${ReceiptTicketFormatters.money(leftValue)} $rightLabel    ${ReceiptTicketFormatters.money(rightValue)} F',
      style: _boldStyle,
    );
  }

  Widget _buildMoneyLine(String label, double value) {
    return Text(
      '$label     ${ReceiptTicketFormatters.money(value).padLeft(8, ' ')} F',
    );
  }

  Widget _centerText(String text, {TextStyle? style}) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style ?? _textStyle,
      ),
    );
  }
}

class ReceiptPreviewDialog extends StatelessWidget {
  const ReceiptPreviewDialog({
    super.key,
    required this.title,
    required this.data,
    this.onDownload,
  });

  final String title;
  final ReceiptTicketData data;
  final Future<void> Function()? onDownload;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 860),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: BpColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Center(child: ReceiptTicket(data: data)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fermer'),
                    ),
                  ),
                  if (onDownload != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await onDownload!();
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Telecharger'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
