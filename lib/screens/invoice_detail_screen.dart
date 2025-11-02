/**
 * Invoice Detail Screen
 * 
 * Displays invoice preview and generates PDF e-bill
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../data/database.dart';
import '../providers/database_provider.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  List<InvoiceItem> _items = [];
  Map<String, String> _businessSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  Future<void> _loadInvoiceData() async {
    final database = ref.read(databaseProvider);

    // Load invoice items
    final items = await database.getInvoiceItems(widget.invoice.id);

    // Load business settings
    final settings = {
      'businessName':
          await database.getSetting('businessName') ?? 'Your Business',
      'businessAddress': await database.getSetting('businessAddress') ?? '',
      'businessPhone': await database.getSetting('businessPhone') ?? '',
      'businessEmail': await database.getSetting('businessEmail') ?? '',
      'gstin': await database.getSetting('gstin') ?? '',
      'upiId': await database.getSetting('upiId') ?? '',
    };

    setState(() {
      _items = items;
      _businessSettings = settings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printInvoice,
            tooltip: 'Print',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveInvoice,
            tooltip: 'Save to Files',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildInvoicePreview(),
      ),
    );
  }

  Widget _buildInvoicePreview() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _businessSettings['businessName'] ?? 'Your Business',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_businessSettings['businessAddress']!.isNotEmpty)
                        Text(_businessSettings['businessAddress']!),
                      if (_businessSettings['businessPhone']!.isNotEmpty)
                        Text('Phone: ${_businessSettings['businessPhone']}'),
                      if (_businessSettings['businessEmail']!.isNotEmpty)
                        Text('Email: ${_businessSettings['businessEmail']}'),
                      if (_businessSettings['gstin']!.isNotEmpty)
                        Text('GSTIN: ${_businessSettings['gstin']}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 2),

            // Invoice Title
            const Center(
              child: Text(
                'TAX INVOICE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Invoice Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice No: ${widget.invoice.invoiceNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date: ${dateFormat.format(widget.invoice.invoiceDate)}',
                    ),
                    if (widget.invoice.dueDate != null)
                      Text(
                        'Due Date: ${dateFormat.format(widget.invoice.dueDate!)}',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bill To:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.invoice.customerName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.invoice.customerPhone != null)
                    Text(widget.invoice.customerPhone!),
                  if (widget.invoice.customerAddress != null)
                    Text(widget.invoice.customerAddress!),
                  if (widget.invoice.customerGstin != null)
                    Text('GSTIN: ${widget.invoice.customerGstin}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Items Table
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(0.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '#',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'HSN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Rate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Items
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name),
                            Text(
                              'GST ${item.gstRate}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item.hsnCode ?? '-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${item.quantity} ${item.unit}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(currencyFormat.format(item.price)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(currencyFormat.format(item.amount)),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal:', widget.invoice.subtotal),
                      if (widget.invoice.discount > 0)
                        _buildTotalRow('Discount:', -widget.invoice.discount),
                      _buildTotalRow(
                        'Taxable Value:',
                        widget.invoice.taxableValue,
                      ),
                      _buildTotalRow('CGST:', widget.invoice.cgst),
                      _buildTotalRow('SGST:', widget.invoice.sgst),
                      if (widget.invoice.igst > 0)
                        _buildTotalRow('IGST:', widget.invoice.igst),
                      const Divider(thickness: 2),
                      _buildTotalRow(
                        'Total:',
                        widget.invoice.total,
                        isBold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Notes
            if (widget.invoice.notes != null &&
                widget.invoice.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.invoice.notes!),
            ],

            // Footer
            const SizedBox(height: 32),
            if (_businessSettings['upiId']!.isNotEmpty) ...[
              const Text(
                'Payment Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('UPI ID: ${_businessSettings['upiId']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await _generatePdf(),
    );
  }

  Future<void> _shareInvoice() async {
    try {
      final pdfData = await _generatePdf();
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/${widget.invoice.invoiceNumber}.pdf',
      );
      await file.writeAsBytes(pdfData);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice ${widget.invoice.invoiceNumber}',
        text: 'Please find attached invoice ${widget.invoice.invoiceNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing invoice: $e')));
      }
    }
  }

  Future<void> _saveInvoice() async {
    try {
      final pdfData = await _generatePdf();
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/${widget.invoice.invoiceNumber}.pdf',
      );
      await file.writeAsBytes(pdfData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice saved to ${file.path}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => _shareInvoice(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving invoice: $e')));
      }
    }
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');

    // Load logo if exists (optional)
    pw.ImageProvider? logo;
    try {
      final logoData = await rootBundle.load('assets/logo.png');
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo not found, continue without it
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header with logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _businessSettings['businessName'] ?? 'Your Business',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    if (_businessSettings['businessAddress']!.isNotEmpty)
                      pw.Text(_businessSettings['businessAddress']!),
                    if (_businessSettings['businessPhone']!.isNotEmpty)
                      pw.Text('Phone: ${_businessSettings['businessPhone']}'),
                    if (_businessSettings['businessEmail']!.isNotEmpty)
                      pw.Text('Email: ${_businessSettings['businessEmail']}'),
                    if (_businessSettings['gstin']!.isNotEmpty)
                      pw.Text('GSTIN: ${_businessSettings['gstin']}'),
                  ],
                ),
                if (logo != null)
                  pw.Container(width: 80, height: 80, child: pw.Image(logo)),
              ],
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 16),

            // Invoice Title
            pw.Center(
              child: pw.Text(
                'TAX INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            pw.SizedBox(height: 16),

            // Invoice Details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Invoice No: ${widget.invoice.invoiceNumber}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Date: ${dateFormat.format(widget.invoice.invoiceDate)}',
                    ),
                    if (widget.invoice.dueDate != null)
                      pw.Text(
                        'Due Date: ${dateFormat.format(widget.invoice.dueDate!)}',
                      ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Customer Details
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bill To:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    widget.invoice.customerName,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  if (widget.invoice.customerPhone != null)
                    pw.Text(widget.invoice.customerPhone!),
                  if (widget.invoice.customerAddress != null)
                    pw.Text(widget.invoice.customerAddress!),
                  if (widget.invoice.customerGstin != null)
                    pw.Text('GSTIN: ${widget.invoice.customerGstin}'),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Items Table
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '#',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'HSN',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Rate',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Items
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('${index + 1}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.name),
                            pw.Text(
                              'GST ${item.gstRate}%',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(item.hsnCode ?? '-'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('${item.quantity} ${item.unit}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('₹${item.price.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('₹${item.amount.toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  child: pw.Column(
                    children: [
                      _buildPdfTotalRow('Subtotal:', widget.invoice.subtotal),
                      if (widget.invoice.discount > 0)
                        _buildPdfTotalRow(
                          'Discount:',
                          -widget.invoice.discount,
                        ),
                      _buildPdfTotalRow(
                        'Taxable Value:',
                        widget.invoice.taxableValue,
                      ),
                      _buildPdfTotalRow('CGST:', widget.invoice.cgst),
                      _buildPdfTotalRow('SGST:', widget.invoice.sgst),
                      if (widget.invoice.igst > 0)
                        _buildPdfTotalRow('IGST:', widget.invoice.igst),
                      pw.Divider(thickness: 2),
                      _buildPdfTotalRow(
                        'Total:',
                        widget.invoice.total,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Notes
            if (widget.invoice.notes != null &&
                widget.invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text(
                'Notes:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(widget.invoice.notes!),
            ],

            // Footer
            pw.SizedBox(height: 24),
            if (_businessSettings['upiId']!.isNotEmpty) ...[
              pw.Text(
                'Payment Info:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('UPI ID: ${_businessSettings['upiId']}'),
            ],
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Thank you for your business!',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfTotalRow(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
