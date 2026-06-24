import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/enums.dart';
import '../models/sale.dart';
import '../core/app_styles.dart';

class InvoicePdfService {
  static const _gold = PdfColor.fromInt(0xFF8B5E00);
  static const _bg = PdfColor.fromInt(0xFFF7F3EC);
  static const _black = PdfColors.black;
  static const _grey = PdfColor.fromInt(0xFF9E9E9E);
  static const _lightGrey = PdfColor.fromInt(0xFFEEEEEE);
  static const _green = PdfColor.fromInt(0xFF119C1A);
  static const _red = PdfColor.fromInt(0xFFB00020);
  static const _redTint = PdfColor.fromInt(0xFFFDE8EC);
  static const _greenTint = PdfColor.fromInt(0xFFE8F5E9);
  static const _greyTint = PdfColor.fromInt(0xFFF5F5F5);

  static Future<void> downloadInvoice(Sale sale) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontSemiBold = await PdfGoogleFonts.nunitoSemiBold();

    // Load logo
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final customerLabel = (sale.customerName?.isNotEmpty == true)
        ? sale.customerName!
        : 'Walk-in Customer';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header band
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: pw.BoxDecoration(
                  color: _gold,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Logo + app name
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Image(logoImage, width: 40, height: 40),
                        pw.SizedBox(width: 12),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('STOCKSENSE',
                                style: pw.TextStyle(
                                    font: fontBold,
                                    fontSize: 22,
                                    color: PdfColors.white)),
                            pw.SizedBox(height: 2),
                            pw.Text('Sales Invoice',
                                style: pw.TextStyle(
                                    font: font,
                                    fontSize: 12,
                                    color: PdfColors.white)),
                          ],
                        ),
                      ],
                    ),
                    // Receipt + date
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Receipt #${sale.receiptNumber}',
                            style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                                color: PdfColors.white)),
                        pw.SizedBox(height: 4),
                        pw.Text(formatDate(sale.saleDate),
                            style: pw.TextStyle(
                                font: font,
                                fontSize: 11,
                                color: PdfColors.white)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Customer + status row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO',
                          style: pw.TextStyle(
                              font: fontSemiBold,
                              fontSize: 9,
                              color: _grey,
                              letterSpacing: 1.2)),
                      pw.SizedBox(height: 4),
                      pw.Text(customerLabel,
                          style: pw.TextStyle(
                              font: fontBold, fontSize: 14, color: _black)),
                    ],
                  ),
                  pw.Row(
                    children: [
                      _badge(sale.saleStatus.value.toUpperCase(), _green, _greenTint, fontSemiBold),
                      pw.SizedBox(width: 8),
                      _badge(sale.saleChannel.label.toUpperCase(), _grey, _greyTint, fontSemiBold),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: _lightGrey),
              pw.SizedBox(height: 12),

              //  Items table header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: _bg,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.Text('ITEM', style: pw.TextStyle(font: fontSemiBold, fontSize: 9, color: _grey, letterSpacing: 1))),
                    pw.Expanded(flex: 1, child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontSemiBold, fontSize: 9, color: _grey, letterSpacing: 1))),
                    pw.Expanded(flex: 2, child: pw.Text('UNIT PRICE', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontSemiBold, fontSize: 9, color: _grey, letterSpacing: 1))),
                    pw.Expanded(flex: 2, child: pw.Text('AMOUNT', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontSemiBold, fontSize: 9, color: _grey, letterSpacing: 1))),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              //  Items
              ...sale.items.asMap().entries.map((e) {
                final i = e.value;
                final isEven = e.key.isEven;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : _bg,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(i.productName, style: pw.TextStyle(font: fontSemiBold, fontSize: 11, color: _black)),
                            if (i.sku != null)
                              pw.Text('SKU: ${i.sku}', style: pw.TextStyle(font: font, fontSize: 9, color: _grey)),
                          ],
                        ),
                      ),
                      pw.Expanded(flex: 1, child: pw.Text('${i.quantity}', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: font, fontSize: 11, color: _black))),
                      pw.Expanded(flex: 2, child: pw.Text('₹${i.unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: font, fontSize: 11, color: _black))),
                      pw.Expanded(flex: 2, child: pw.Text('₹${i.subtotal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontSemiBold, fontSize: 11, color: _black))),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 16),
              pw.Divider(color: _lightGrey),
              pw.SizedBox(height: 12),

              //  Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 220,
                    child: pw.Column(
                      children: [
                        _totalRow('Subtotal', '₹${sale.subtotal.toStringAsFixed(2)}', font, _grey),
                        pw.SizedBox(height: 6),
                        _totalRow('Tax (${sale.taxPercent.toStringAsFixed(1)}%)', '₹${sale.taxAmount.toStringAsFixed(2)}', font, _grey),
                        pw.SizedBox(height: 10),
                        pw.Divider(color: _lightGrey),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('GRAND TOTAL', style: pw.TextStyle(font: fontBold, fontSize: 13, color: _black, letterSpacing: 0.5)),
                            pw.Text('₹${sale.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: fontBold, fontSize: 18, color: _gold)),
                          ],
                        ),
                        if (sale.paymentModeEnum == SalePaymentMode.partial && sale.paidAmount > 0) ...[
                          pw.SizedBox(height: 6),
                          _totalRow('Paid Now', '₹${sale.paidAmount.toStringAsFixed(2)}', fontSemiBold, _green),
                        ],
                        if ((sale.paymentModeEnum == SalePaymentMode.credit || sale.paymentModeEnum == SalePaymentMode.partial) && sale.creditAmount > 0) ...[
                          pw.SizedBox(height: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: _redTint,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('CREDIT DUE', style: pw.TextStyle(font: fontBold, fontSize: 11, color: _red, letterSpacing: 0.5)),
                                pw.Text('₹${sale.creditAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: fontBold, fontSize: 14, color: _red)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: _lightGrey),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Thank you for your purchase · Generated by StockSense',
                  style: pw.TextStyle(font: font, fontSize: 9, color: _grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${sale.receiptNumber}.pdf',
    );
  }

  static pw.Widget _badge(String label, PdfColor color, PdfColor tint, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: tint,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9, color: color)),
    );
  }

  static pw.Widget _totalRow(String label, String value, pw.Font font, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 11, color: color)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 11, color: color)),
      ],
    );
  }
}